
import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CoreData

extension Notification.Name {
	static let pollenDidUpdate = Notification.Name("POLLEN_SAMPLES_DID_UPDATE")
}

let POLLEN_SAMPLE_ENTITY = "CorePollenSample"

class ClinicData {
	static let shared = ClinicData()
	
	// date(toString) : sample
//	var pollenSamples:[String:PollenSamples] = [:]
	var pollenSamples:[PollenSamples] = []

	private init(){
		FirebaseApp.configure()
		// if a new pollen count is taken while the app is open, reload data in app
		Database.database().reference(withPath: "/collections").observe(.value, with: { snapshot in
			NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
		})
	}
	
	func boot(){
		// 1. check core data for stored info:
		//   if entries: search for most recent entry, ask firebase for anything more recent
		//   if no entries: ask firebase for 15 recent entries, load years of data in background

//		clearCoreData()

//		print("mostRecentCoreDataEntryDate()")
//		print(mostRecentCoreDataEntryDate() ?? "")

//		loopAndLoadData(numberOfDays: 15) {
//			if self.mostRecentCoreDataEntryDate() == nil{
//				self.downloadAllSamples()
//			}
//		}
//		self.downloadAllSamples()
		loadSamplesFromCoreData()
	}
	
	func loadSamplesFromCoreData(){
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		let sort = NSSortDescriptor(key: "date", ascending: false)
		fetchRequest.sortDescriptors = [sort]
		do {
			let sampleData:[NSManagedObject] = try managedContext.fetch(fetchRequest)
			self.pollenSamples = sampleData.map({ self.pollenSamplesFromCoreData(data: $0) }).compactMap({ $0 })
			NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
		} catch let error as NSError{ print("could not fetch \(error)") }
	}
	
	func pollenSamplesFromCoreData(data:NSManagedObject) -> PollenSamples?{
		let counts = Pollen.shared.types.map({ ($0.key,data.value(forKey: $0.key)) }).reduce([:]) { (dict, entry) -> [String:Any] in
			var dict = dict
			dict[entry.0] = entry.1
			return dict
		}
		if let date = data.value(forKey: "date") as? Date{
			return PollenSamples(fromDatabase: ["date":date.timeIntervalSince1970, "counts":counts])
		}
		return nil
	}
	
	func mostRecentCoreDataEntryDate() -> Date?{
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		let sort = NSSortDescriptor(key: "date", ascending: false)
		fetchRequest.sortDescriptors = [sort]
		do {
			let sampleData:[NSManagedObject] = try managedContext.fetch(fetchRequest)
			if let first = sampleData.first{
				if let date = first.value(forKey: "date") as? Date{
					return date
				}
			}
		} catch let error as NSError{ print("could not fetch \(error)") }
		return nil
	}
	
//	func coreDataCount() -> Int{
//		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
//		let managedContext = appDelegate.persistentContainer.viewContext
//		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
//		do {
//			let sampleData:[NSManagedObject] = try managedContext.fetch(fetchRequest)
//			return sampleData.count
//		} catch let error as NSError{ print("could not fetch \(error)") }
//		return 0
//	}

	func downloadAllSamples(){
		Database.database().reference().child("collections").observeSingleEvent(of: .value) { (data) in
			if let d = data.value as? [String:[String:Any]]{
				let samplesArray = Array(d.values)
				samplesArray.forEach({
					let samples = PollenSamples(fromDatabase: $0)
					self.saveCoreData(withSamples: samples)
				})
				self.printCoreDataContents()
			}
		}
	}
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func getData(_ childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
		var reference = Database.database().reference()
		if(childURL != nil){
			reference = Database.database().reference().child(childURL!)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				completionHandler(snapshot.value as AnyObject?)
			}
		}
	}

	func clearCoreData(){
		var sampleData: [NSManagedObject] = []
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		do {
			sampleData = try managedContext.fetch(fetchRequest)
			for samples in sampleData{
				managedContext.delete(samples)
			}
			try managedContext.save()
		} catch let error as NSError{
			print("clearCoreData() could not fetch \(error)")
		}
	}
	
	func printCoreDataContents(){
		print("fetching core data")
		var sampleData: [NSManagedObject] = []
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		do {
			sampleData = try managedContext.fetch(fetchRequest)
			print("core data contains \(sampleData.count) entries")
			for samples in sampleData{
				print(samples.value(forKey: "date") ?? "")
				print(samples)
			}
		} catch let error as NSError{
			print("could not fetch \(error)")
		}
		print("end of fetching core data")
	}

	func saveCoreData(withSamples samples:PollenSamples){
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: POLLEN_SAMPLE_ENTITY, in: managedContext)!
		let coreSample = NSManagedObject(entity: entity, insertInto: managedContext)
		samples.getSamples().forEach({ coreSample.setValue($0.value, forKey: $0.type.key) })
		if let date = samples.date{ coreSample.setValue(date, forKey: "date") }
		do{
			try managedContext.save()
//			allergies.append(allergy)
		} catch let error as NSError {
			print("could not save \(error)")
		}
	}
	
	func loopAndLoadData(numberOfDays:Int, completionHandler: (() -> ())? ){
		/*
		var tries = 0
		var successes = 0
		
		func queryOnce(){
			// build date for #days past
			var deltaDate = DateComponents()
			deltaDate.day = -tries
			let queryDate:Date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: Date(), options: NSCalendar.Options.matchFirst)!
			let dateString = collectionsKey(forDate:queryDate)

			tries += 1
			Database.database().reference().child("collections/" + dateString).observeSingleEvent(of: .value) { (data) in
				if let d = data.value as? [String:Any]{
					let samples = PollenSamples(fromDatabase: d)
					if let sampleDate = samples.date{
						let dateString = sampleDate.toString()
						self.pollenSamples[dateString] = samples
						NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
						successes += 1
					}
				} else{
					print("no entry for " + dateString + ". trying again")
				}
				// repeat if we need more days of data
				if(successes < numberOfDays && tries < 100){
					queryOnce()
				} else{
					completionHandler?()
				}
			}
		}
		queryOnce()
		*/
	}
	
	// daysPast is expecting a positive number. ("5" means 5 days ago)
	func collectionsKey(forDate date:Date) -> String{
		let yearNumber:Int = Calendar.current.component(.year, from: date)
		let monthNumber:Int = Calendar.current.component(.month, from: date)
		let dayNumber:Int = Calendar.current.component(.day, from: date)
		return "\(yearNumber)" + String(format: "%02d", monthNumber) + String(format: "%02d", dayNumber)
	}

}

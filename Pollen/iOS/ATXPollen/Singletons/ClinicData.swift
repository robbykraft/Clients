
import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CoreData

extension Notification.Name {
	static let pollenDidUpdate = Notification.Name("POLLEN_SAMPLES_DID_UPDATE")
}


class ClinicData {
	private let POLLEN_SAMPLE_ENTITY = "CorePollenSample"

	static let shared = ClinicData()

	var dailyCounts:[DailyPollenCount] = []

	private init(){
		FirebaseApp.configure()
		// if a new pollen count is taken while the app is open, reload data in app
		Database.database().reference(withPath: "/collections").observe(.value, with: { snapshot in
			NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
		})
	}
	
	func boot(){
		// FOR TESTING remove 2 weeks of recent data
//		let startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
//		let samples = queryCoreDataSamples(between: startDate, endDate: Date())

		loadSamplesFromCoreData()
		
		ChartData.shared.reloadData()

		if let lastEntryDate = mostRecentCoreDataEntryDate(){
			let nextSearchDate = Calendar.current.date(byAdding: .day, value: 1, to: lastEntryDate)!
			let datesToUpdate = self.allDatesBetween(nextSearchDate, endDate: Date())
			self.queryDatabase(for: datesToUpdate, completionHandler: nil)
		} else{
			// this is the first time running the app. download all the data
			self.downloadAllSamples()
		}
	}
	// MARK: dailyCounts to Core Data
	func dailyCountsFromCoreData(data:NSManagedObject) -> DailyPollenCount?{
		let counts = Pollen.shared.types.map({ ($0.key,data.value(forKey: $0.key)) }).reduce([:]) { (dict, entry) -> [String:Any] in
			var dict = dict
			dict[entry.0] = entry.1
			return dict
		}
		if let date = data.value(forKey: "date") as? Date{
			return DailyPollenCount(fromDatabase: ["date":date.timeIntervalSince1970, "counts":counts])
		}
		return nil
	}
	// MARK: Core Data
	func loadSamplesFromCoreData(){
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		let sort = NSSortDescriptor(key: "date", ascending: false)
		fetchRequest.sortDescriptors = [sort]
		do {
			let sampleData:[NSManagedObject] = try managedContext.fetch(fetchRequest)
			self.dailyCounts = sampleData.map({ self.dailyCountsFromCoreData(data: $0) }).compactMap({ $0 })
			NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
		} catch let error as NSError{ print("could not fetch \(error)") }
	}
	func saveCoreData(withSamples samples:DailyPollenCount){
		// search core data for an entry that shares the same date as samples. remove it
		if let samplesDate = samples.date{
			self.deleteCoreData(samplesData: self.queryCoreDataSamples(on: samplesDate))
		}
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: POLLEN_SAMPLE_ENTITY, in: managedContext)!
		let coreSample = NSManagedObject(entity: entity, insertInto: managedContext)
		samples.getSamples().forEach({ coreSample.setValue($0.value, forKey: $0.type.key) })
		if let date = samples.date{ coreSample.setValue(date, forKey: "date") }
		do{ try managedContext.save() }
		catch let error as NSError { print("could not save \(error)") }
	}
	func queryCoreDataSamples(on date:Date) -> [NSManagedObject]{
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		let cal = Calendar.current
		let startOfDay = cal.startOfDay(for: date)
		let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
		fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay as NSDate, endOfDay as NSDate)
		do{ return try managedContext.fetch(fetchRequest) }
		catch { return [] }
	}
	func queryCoreDataSamples(between startDate:Date, endDate:Date) -> [NSManagedObject]{
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: POLLEN_SAMPLE_ENTITY)
		let cal = Calendar.current
		let startOfStartDay = cal.startOfDay(for: startDate)
		let endOfEndDay = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: endDate)!)
		fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startOfStartDay as NSDate, endOfEndDay as NSDate)
		do{ return try managedContext.fetch(fetchRequest) }
		catch { return [] }
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
				if let date = first.value(forKey: "date") as? Date{ return date }
			}
		} catch { return nil }
		return nil
	}
	@discardableResult func deleteCoreData(samplesData:[NSManagedObject]) -> Bool{
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
		let managedContext = appDelegate.persistentContainer.viewContext
		do{
			for samples in samplesData{ managedContext.delete(samples) }
			try managedContext.save()
			return true
		} catch{ return false }
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
	// MARK: Firebase Database
	// encode a date in the manner they are used in the JSON database
	func collectionsKey(forDate date:Date) -> String{
		let yearNumber:Int = Calendar.current.component(.year, from: date)
		let monthNumber:Int = Calendar.current.component(.month, from: date)
		let dayNumber:Int = Calendar.current.component(.day, from: date)
		return "\(yearNumber)" + String(format: "%02d", monthNumber) + String(format: "%02d", dayNumber)
	}
	func downloadAllSamples(){
		Database.database().reference().child("collections").observeSingleEvent(of: .value) { (data) in
			if let d = data.value as? [String:[String:Any]]{
				let samplesArray = Array(d.values)
				samplesArray.forEach({
					self.saveCoreData(withSamples: DailyPollenCount(fromDatabase: $0))
				})
				self.loadSamplesFromCoreData()
			}
		}
	}
	func queryDatabase(for dates:[Date], completionHandler: (() -> ())? ){
		var dateKeys = dates.map({ self.collectionsKey(forDate: $0) })
		func queryDate(key:String){
			Database.database().reference().child("collections/" + key).observeSingleEvent(of: .value) { (data) in
				if let d = data.value as? [String:Any]{
					self.saveCoreData(withSamples: DailyPollenCount(fromDatabase: d))
					self.loadSamplesFromCoreData()
					NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
				}
				else{ print("no entry for " + key) }
				if let index = dateKeys.index(of: key){
					dateKeys.remove(at: index)
					if let firstKey = dateKeys.first{ queryDate(key: firstKey) }
					else{
						print("finished checking dates")
						completionHandler?()
					}
				} else{
					// something went wrong, breaking to prevent infinite loop
				}
			}
		}
		// run the function
		if let firstKey = dateKeys.first{
			queryDate(key: firstKey)
		}
	}

	func allDatesBetween(_ startDate: Date, endDate: Date) -> [Date] {
		var datesArray: [Date] =  []
		var startDate = startDate
		let calendar = Calendar.current
		while startDate <= endDate {
			datesArray.append(startDate)
			startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
		}
		return datesArray
	}

}

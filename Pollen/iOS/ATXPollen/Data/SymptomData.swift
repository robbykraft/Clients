//
//  SymptomData.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/6/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Notification.Name {
	static let symptomDidUpdate = Notification.Name("SYMPTOM_ENTRY_DID_UPDATE")
}


class Symptom {
	private let SYMPTOM_SAMPLE_ENTITY = "CoreSymptomSample"

	static let shared = Symptom()
	
	// date(toString) : sample
	var entries:[SymptomEntry] = []
	
	private init(){
		loadSamplesFromCoreData()
	}
	
	func clearDataAndMakeFakeData(){
		clearCoreData()
		var symptoms:[SymptomEntry] = []
		for i in 0..<40{
			var components = DateComponents()
			components.day = -i
			let date = Calendar.current.date(byAdding: components, to: Date())!
			let rand = Int(arc4random() % 5)
			var exposures:[Exposures]? = nil
			let possibleExposures:[Exposures] = [.dog,.cat,.molds,.dust,.virus]
			for i in 0..<possibleExposures.count{
				if Int(arc4random() % 4) == 0{
					if exposures == nil{
						exposures = [possibleExposures[i]]
					}
					else { exposures!.append(possibleExposures[i]) }
				}
			}
			let rating = (rand < 4) ? SymptomRating(rawValue: rand) : nil
			symptoms.append(SymptomEntry(date: date, location: nil, rating: rating, exposures: exposures))
		}
		
		do{
		try symptoms.forEach { (entry) in
			guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
			let managedContext = appDelegate.persistentContainer.viewContext
			var object = self.queryCoreDataSamples(on: entry.date).first
			if object == nil{
				let entity = NSEntityDescription.entity(forEntityName: SYMPTOM_SAMPLE_ENTITY, in: managedContext)!
				object = NSManagedObject(entity: entity, insertInto: managedContext)
			}
			guard let coreSample = object else{ print("error finding and/or creating symptom object"); return }
			coreSample.setValue(entry.date, forKey: "date")
			if let rating = entry.rating{
				coreSample.setValue(rating.rawValue, forKey: "rating")
			} else{
				coreSample.setValue(nil, forKey: "rating")
			}
			if let location = entry.location{
				coreSample.setValue(location.0, forKey: "latitude")
				coreSample.setValue(location.1, forKey: "longitude")
			} else{
				coreSample.setValue(nil, forKey: "latitude")
				coreSample.setValue(nil, forKey: "longitude")
			}
			if let exposures = entry.exposures{
				coreSample.setValue(exposures.map({$0.asString()}).joined(separator: ","), forKey: "exposures")
			} else{
				coreSample.setValue(nil, forKey: "exposures")
			}
			try managedContext.save()
		}
		} catch{
			
		}

		loadSamplesFromCoreData()
	}
	
	// MARK: convert Core Data to SymptomEntry
	func symptomEntryFromCoreData(data:NSManagedObject) -> SymptomEntry?{
		let latitude = data.value(forKey: "latitude") as? Double
		let longitude = data.value(forKey: "longitude") as? Double
		let location = (latitude != nil && longitude != nil) ? (latitude!, longitude!) : nil
		let rating = data.value(forKey: "rating") != nil ? SymptomRating(rawValue: data.value(forKey: "rating") as! Int) : nil
		var exposures:[Exposures]?
		if let exposureString = data.value(forKey: "exposures") as? String{
			exposures = exposureString
				.components(separatedBy: ",")
				.compactMap({ (string) -> Exposures? in
					return exposureFromString(string: string)
				})
		}
		if let date = data.value(forKey: "date") as? Date{
			return SymptomEntry(date: date, location: location, rating: rating, exposures: exposures)
		}
		return nil
	}
	
	// MARK: Core Data
	func loadSamplesFromCoreData(){
		print("loading samples")
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SYMPTOM_SAMPLE_ENTITY)
		let sort = NSSortDescriptor(key: "date", ascending: false)
		fetchRequest.sortDescriptors = [sort]
		do {
			let sampleData:[NSManagedObject] = try managedContext.fetch(fetchRequest)
			self.entries = sampleData.map({ self.symptomEntryFromCoreData(data: $0) }).compactMap({ $0 })
			NotificationCenter.default.post(name: .symptomDidUpdate, object: nil)
		} catch let error as NSError{ print("could not fetch \(error)") }
	}
	
//	func replaceDatabaseWith(entry:SymptomEntry){
//		// search core data for an entry that fits within the same time window
//		self.deleteCoreData(samplesData: self.queryCoreDataSamples(on: entry.date))
//		updateDatabaseWith(entry: entry)
//	}
	
	func updateDatabaseWith(entry:SymptomEntry){
		// only allows 1 entry per date. if one exists it will replace data
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		var object = self.queryCoreDataSamples(on: entry.date).first
		if object == nil{
			let entity = NSEntityDescription.entity(forEntityName: SYMPTOM_SAMPLE_ENTITY, in: managedContext)!
			object = NSManagedObject(entity: entity, insertInto: managedContext)
		}
		guard let coreSample = object else{ print("error finding and/or creating symptom object"); return }
		coreSample.setValue(entry.date, forKey: "date")
		if let rating = entry.rating{
			coreSample.setValue(rating.rawValue, forKey: "rating")
		} else{
			coreSample.setValue(nil, forKey: "rating")
		}
		if let location = entry.location{
			coreSample.setValue(location.0, forKey: "latitude")
			coreSample.setValue(location.1, forKey: "longitude")
		} else{
			coreSample.setValue(nil, forKey: "latitude")
			coreSample.setValue(nil, forKey: "longitude")
		}
		if let exposures = entry.exposures{
			coreSample.setValue(exposures.map({$0.asString()}).joined(separator: ","), forKey: "exposures")
		} else{
			coreSample.setValue(nil, forKey: "exposures")
		}
		do{
			try managedContext.save()
			loadSamplesFromCoreData()
		}
		catch let error as NSError { print("could not save \(error)") }
	}
	
	func clearCoreData(){
		var sampleData: [NSManagedObject] = []
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SYMPTOM_SAMPLE_ENTITY)
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

	func queryCoreDataSamples(on date:Date) -> [NSManagedObject]{
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SYMPTOM_SAMPLE_ENTITY)
		let cal = Calendar.current
		let startOfDay = cal.startOfDay(for: date)
		let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
		fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfDay as NSDate, endOfDay as NSDate)
		do{ return try managedContext.fetch(fetchRequest) }
		catch { return [] }
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

}

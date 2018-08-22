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

class Symptom {
	private let SYMPTOM_SAMPLE_ENTITY = "CoreSymptomSample"

	static let shared = Symptom()
	
	// date(toString) : sample
	var entries:[SymptomEntry] = []
	
	private init(){
//		clearCoreData()
//		loadFakeData()
		loadSamplesFromCoreData()
	}
	
	func loadFakeData(){
		var symptoms:[SymptomEntry] = []
		for i in 0..<60{
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
		symptoms.forEach({ updateDatabaseWith(entry: $0) })
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
	
	func updateDatabaseWith(entry:SymptomEntry){
		// search core data for an entry that fits within the same time window
//		if let samplesDate = samples.date{
//			self.deleteCoreData(samplesData: self.queryCoreDataSamples(on: samplesDate))
//		}
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: SYMPTOM_SAMPLE_ENTITY, in: managedContext)!
		let coreSample = NSManagedObject(entity: entity, insertInto: managedContext)
		coreSample.setValue(entry.date, forKey: "date")
		if let rating = entry.rating{ coreSample.setValue(rating.rawValue, forKey: "rating") }
		if let location = entry.location{
			coreSample.setValue(location.0, forKey: "latitude")
			coreSample.setValue(location.1, forKey: "longitude")
		}
		if let exposures = entry.exposures{
			coreSample.setValue(exposures.map({$0.asString()}).joined(separator: ","), forKey: "exposures")
		}
		do{ try managedContext.save() }
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

}

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
//		loadFakeData()
	}
	
	func boot(){
		// 1. check core data for stored info:
		//   if entries: search for most recent entry, ask firebase for anything more recent
		//   if no entries: ask firebase for 15 recent entries, load years of data in background
		
		//		clearCoreData()
		
		//		print("mostRecentCoreDataEntryDate()")
		//		print(mostRecentCoreDataEntryDate() ?? "")

//		loadSamplesFromCoreData()
	}
	
	func loadFakeData(){
		let fakeData:[String:Int] = ["2018-05-10":0,
									 "2018-05-11":0,
									 "2018-05-12":2,
									 "2018-05-13":1,
									 "2018-05-14":2,
									 "2018-05-15":3,
									 "2018-05-16":3,
									 "2018-05-17":2,
									 "2018-05-18":3,
									 "2018-05-24":0,
									 "2018-05-25":0,
									 "2018-05-26":2,
									 "2018-05-27":2,
									 "2018-05-28":2,
									 "2018-05-30":1,
									 "2018-06-01":0,
									 "2018-06-02":3]
		var symptomEntries:[SymptomEntry] = []

		for (key,value) in fakeData{
			let date = Date(fromString: key)!
			let exposuresArray:[Exposures] = [Exposures.cat, Exposures.dog, Exposures.dust, Exposures.molds, Exposures.virus].filter({ _ in arc4random_uniform(100) < 40 })
			let s = SymptomEntry(date: date, location: nil, rating: SymptomRating(rawValue: value), exposures: exposuresArray)
			symptomEntries.append(s)
		}
		self.entries = symptomEntries
	}
	
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
	// MARK: Core Data to SymptomEntry
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


}

//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 11/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

extension Date{
	func toString() -> String{
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: self)
	}
	init?(fromString:String){
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		if let success = formatter.date(from: fromString){ self = success }
		else { return nil }
	}
//	mutating func from(string:String){
//		let formatter = DateFormatter()
//		formatter.dateFormat = "yyyy-MM-dd"
//		if let success = formatter.date(from: string){ self = success }
//	}
}

class AllergyEntry: NSObject {
	var date:Date
	var allergies:[ String:[String:Int] ] = [:]
	
	func updateRecord(category:String, symptom:String, degree:Int){
		if self.allergies[category] != nil{
			//entry exists
			self.allergies[category]![symptom] = degree
		} else{
			//entry doesn't exist, make first one
			self.allergies[category] = [symptom:degree]
		}
	}
	func removeRecord(category:String, symptom:String){
		if self.allergies[category] != nil{
			//entry exists
			self.allergies[category]![symptom] = nil
		}
	}
	func dictionary() -> [String:[String:Int]]{
		return self.allergies
	}
	override init() {
		// dates are initialized to NOW time, in user's time zone
		self.date = Date()
		super.init()
	}
	init(date:Date, record:[String:[String:Int]]){
		self.date = date
		self.allergies = record
	}
}

class Allergies {
	static let shared = Allergies()
	
	var records:[String:AllergyEntry] = [:]
	
	fileprivate init(){
		boot()
	}
	
	//                    category symptom   date : rating
	func symptomsData() -> [String:[String:[String:Int]]]{
		var dict:[String:[String:[String:Int]]] = [:]
		for (date,record) in self.records{
			for (category,symptomRating) in record.allergies{
				for (symptom,rating) in symptomRating{
					if (dict[category] == nil){ dict[category] = [:] }
					if (dict[category]![symptom] == nil){ dict[category]![symptom] = [:] }
					dict[category]![symptom]![date] = rating
				}
			}
		}
		return dict
	}
	//        category+symptom    date : rating
	func chartData() -> [String:[String:Int]]{
		let data = self.symptomsData()
		var dict:[String:[String:Int]] = [:]
		for (category,symptomData) in data{
			for (symptom,data) in symptomData{
//				let title:String = "\(symptom) \(category)"
				let title:String = "\(category.uppercased()) \(symptom)"
				dict[title] = data
			}
		}
		return dict
	}
	
	func boot(){
//		UserDefaults.standard.set([String:String](), forKey: "records")
//		UserDefaults.standard.synchronize()
		reloadFromDefaults()
	}
	
	func updateRecord(date:Date, category:String, removeSymptom:String){
		let dateString = date.toString()
		if self.records[dateString] == nil{
			// create first entry in new record
			self.records[dateString] = AllergyEntry()
		}
		self.records[dateString]!.removeRecord(category: category, symptom: removeSymptom)
		self.synchronize()
	}

	func updateRecord(date:Date, category:String, symptom:String, degree:Int){
		let dateString = date.toString()
		if self.records[dateString] == nil{
			// create first entry in new record
			self.records[dateString] = AllergyEntry()
		}
		self.records[dateString]!.updateRecord(category: category, symptom: symptom, degree: degree)
		self.synchronize()
	}
	
	func getRecord(date:Date, category:String, symptom:String)->Int?{
		let dateString = date.toString()
		if self.records[dateString] == nil{
			return nil
		}
		if let entry = self.records[dateString]{
			if let cat = entry.allergies[category]{
				return cat[symptom]
			} else{ return nil }
		} else{ return nil }
	}
	
	func reloadFromDefaults(){
		if let records = UserDefaults.standard.object(forKey: "records") as? [String: [String:[String:Int]] ]{
			print("from ns user defaults")
			print(records)
			for (k,v) in records{
				if let date = Date(fromString: k){
					let record = AllergyEntry(date: date, record: v)
					print(k)
					print(record)
					self.records[k] = record
				}
			}
			print(self.records)
		} else{
			print("no user defaults found")
		}
	}
	
	func synchronize(){
		var recordsDictionary:[String:[String:[String:Int]]] = [:]
		for (k,v) in self.records{
			recordsDictionary[k] = v.dictionary()
		}
//		print("synchronizing user defaults")
//		print(recordsDictionary)
		UserDefaults.standard.set(recordsDictionary, forKey: "records")
		UserDefaults.standard.synchronize()
	}
}

let SymptomCategories = [
	"eyes",
	"sinus",
	"nose",
	"throat",
	"lungs",
	"headache",
	"skin",
	"pet",
	"mold",
	"dust",
	"outdoors",
	"woke up",
	"night time",
	"energy level",
	"meds"
]

// these are the images in the iOS application image directory
let SymptomImageNames = [
	"eyes" : "eye",
	"sinus" : "sinus",
	"nose" : "nose",
	"throat" : "throat",
	"lungs" : "lungs",
	"headache" : "headache",
	"skin" : "skin",
	"pet" : "pet",
	"mold" : "mold",
	"dust" : "dust",
	"outdoors" : "outdoors",
	"woke up" : "wokeup",
	"night time" : "nighttime",
	"energy level" : "energylevel",
	"meds" : "meds"
]


let BinaryCategories = [
	"eyes" : false,
	"sinus" : false,
	"nose" : false,
	"throat" : false,
	"lungs" : false,
	"headache" : false,
	"skin" : false,
	"pet" : true,
	"mold" : true,
	"dust" : true,
	"outdoors" : true,
	"woke up" : true,
	"night time" : true,
	"energy level" : true,
	"meds" : true
]


let SymptomNames = [
	"eyes" : ["itchy", "red", "watery", "bags"],
	"sinus" : ["pressure", "pain", "colored discharge", "tooth pain"],
	"nose" : ["stuffy", "itchy", "runny", "blood"],
	"throat" : ["clearing", "sore", "hoarse voice", "itchy / scratchy"],
	"lungs" : ["wheeze", "cough", "tight chest", "short breath"],
	"skin" : ["itch", "bumps / hives", "eczema", "swelling"],
	"meds" : ["decongestant", "expectorant", "antihistamine", "nose spray"],
	"woke up" : ["groggy head", "stuffed up", "crusty eyes", "dry lips"],
	"night time" : ["stuffy", "cough", "throat drainage", "wheezy chest"],
	"pet" : ["dog", "cat", "rodent", "horse"],
	"mold" : ["home", "work", "school", "other"],
	"dust" : ["home", "work", "school", "other"],
	"outdoors" : ["playing sports", "air travel", "someone sick", "air pollution"],
	"energy level" : ["great", "foggy", "tired", "sick"],
	"headache" : ["forehead", "sides", "back", "behind eyes"]
]

enum eyes_allergies:String { case itchy, red, watery, bags }
enum sinus_allergies:String { case pressure, pain, colored_discharge = "colored discharge", tooth_pain = "tooth pain" }
enum nose_allergies:String { case stuffy, itchy, runny, blood }
enum throat_allergies:String { case clearing, sore, hoarse_voice = "hoarse voice", itchy_scratchy = "itchy / scratchy" }
enum lungs_allergies:String { case wheeze, cough, tight_chest = "tight chest", short_breath = "short breath" }
enum skin_allergies:String { case itch, bumps_hives = "bumps / hives", eczema, swelling }
enum meds_allergies:String { case pill, nose_spray = "nose spray", inhaler, topical_cream = "topical cream" }
enum wokeUp_allergies:String { case groggy_head = "groggy head", stuffed_up = "stuffed up", crusty_eyes = "crusty eyes", dry_lips = "dry lips" }
enum nightTime_allergies:String { case stuffy, cough, throat_drainage = "throat drainage", wheezy_chest = "wheezy chest" }
enum pet_allergies:String { case dog, cat, rodent, horse }
enum mold_allergies:String { case home, work, school, other }
enum dust_allergies:String { case home, work, school, other }
enum outdoors_allergies:String { case playing_sports = "playing sports", air_travel = "air travel", someone_sick = "someone sick", air_pollution = "air pollution" }
enum energyLevel_allergies:String { case great, medium, low, sick }
enum headache_allergies:String { case forehead, sides, back, behind_eyes = "behind eyes" }

let Symptoms = [
	"eyes" : [ eyes_allergies.itchy, eyes_allergies.red, eyes_allergies.watery, eyes_allergies.bags ],
	"sinus" : [ sinus_allergies.pressure, sinus_allergies.pain, sinus_allergies.colored_discharge, sinus_allergies.tooth_pain ],
	"nose" : [ nose_allergies.stuffy, nose_allergies.itchy, nose_allergies.runny, nose_allergies.blood ],
	"throat" : [ throat_allergies.clearing, throat_allergies.sore, throat_allergies.hoarse_voice, throat_allergies.itchy_scratchy ],
	"lungs" : [ lungs_allergies.wheeze, lungs_allergies.cough, lungs_allergies.tight_chest, lungs_allergies.short_breath ],
	"skin" : [ skin_allergies.itch, skin_allergies.bumps_hives, skin_allergies.eczema, skin_allergies.swelling ],
	"meds" : [ meds_allergies.pill, meds_allergies.nose_spray, meds_allergies.inhaler, meds_allergies.topical_cream ],
	"woke up" : [ wokeUp_allergies.groggy_head, wokeUp_allergies.stuffed_up, wokeUp_allergies.crusty_eyes, wokeUp_allergies.dry_lips ],
	"night time" : [ nightTime_allergies.stuffy, nightTime_allergies.cough, nightTime_allergies.throat_drainage, nightTime_allergies.wheezy_chest ],
	"pet" : [ pet_allergies.dog, pet_allergies.cat, pet_allergies.rodent, pet_allergies.horse ],
	"mold" : [ mold_allergies.home, mold_allergies.work, mold_allergies.school, mold_allergies.other ],
	"dust" : [ dust_allergies.home, dust_allergies.work, dust_allergies.school, dust_allergies.other ],
	"outdoors" : [ outdoors_allergies.playing_sports, outdoors_allergies.air_travel, outdoors_allergies.someone_sick, outdoors_allergies.air_pollution ],
	"energy level" : [ energyLevel_allergies.great, energyLevel_allergies.medium, energyLevel_allergies.low, energyLevel_allergies.sick ],
	"headache" : [ headache_allergies.forehead, headache_allergies.sides, headache_allergies.back, headache_allergies.behind_eyes ]
]



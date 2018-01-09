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
	mutating func from(string:String){
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		if let success = formatter.date(from: string){ self = success }
	}
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
	
	func boot(){
//		UserDefaults.standard.set([String:String](), forKey: "records")
//		UserDefaults.standard.synchronize()
		reloadFromDefaults()
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
	
	func reloadFromDefaults(){
		if let records = UserDefaults.standard.object(forKey: "records") as? [String: [String:[String:Int]] ]{
			print("from ns user defaults")
			print(records)
			for (k,v) in records{
				var date = Date()
				date.from(string: k)
				let record = AllergyEntry(date: date, record: v)
				self.records[k] = record
			}
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
	"skin",
	"meds",
	"woke up",
	"night time",
	"pet",
	"mold",
	"dust",
	"outdoors",
	"energy level",
	"headache"
]

let SymptomNames = [
	"eyes" : ["itchy", "red", "watery", "bags"],
	"sinus" : ["pressure", "pain", "colored discharge", "tooth pain"],
	"nose" : ["stuffy", "itchy", "runny", "blood"],
	"throat" : ["clearing", "sore", "hoarse voice", "itchy / scratchy"],
	"lungs" : ["wheeze", "cough", "tight chest", "short breath"],
	"skin" : ["itch", "bumps / hives", "eczema", "swelling"],
	"meds" : ["pill", "nose spray", "inhaler", "topical cream"],
	"woke up" : ["groggy head", "stuffed up", "crusty eyes", "dry lips"],
	"night time" : ["stuffy", "cough", "throat drainage", "wheezy chest"],
	"pet" : ["dog", "cat", "rodent", "horse"],
	"mold" : ["home", "work", "school", "other"],
	"dust" : ["home", "work", "school", "other"],
	"outdoors" : ["playing sports", "air travel", "someone sick", "air pollution"],
	"energy level" : ["great", "medium", "low", "sick"],
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


//let symptomArray = [
//	["itchy", "red", "watery", "bags"],									// eyes
//	["pressure", "pain", "colored discharge", "tooth pain"],			// sinus
//	["stuffy", "itchy", "runny", "blood"],								// nose
//	["clearing", "sore", "hoarse voice", "itchy / scratchy"],			// throat
//	["wheeze", "cough", "tight chest", "short breath"],					// lungs
//	["itch", "bumps / hives", "eczema", "swelling"],					// skin
//	["pill", "nose spray", "inhaler", "topical cream"],					// meds
//	["groggy head", "stuffed up", "crusty eyes", "dry lips"],			// wokeUp
//	["stuffy", "cough", "throat drainage", "wheezy chest"],				// nightTime
//	["dog", "cat", "rodent", "horse"],									// pet
//	["home", "work", "school", "other"],								// mold
//	["home", "work", "school", "other"],								// dust
//	["playing sports", "air travel", "someone sick", "air pollution"],	// outdoors
//	["great", "medium", "low", "sick"],									// energyLevel
//	["forehead", "sides", "back", "behind eyes"]						// headache
//]


/*
struct AllergyResponse{
	var eyes:[eyes_allergies]?
	var sinus:[sinus_allergies]?
	var nose:[nose_allergies]?
	var throat:[throat_allergies]?
	var lungs:[lungs_allergies]?
	var skin:[skin_allergies]?
	var meds:[meds_allergies]?
	var wokeUp:[wokeUp_allergies]?
	var nightTime:[nightTime_allergies]?
	var pet:[pet_allergies]?
	var mold:[mold_allergies]?
	var dust:[dust_allergies]?
	var outdoors:[outdoors_allergies]?
	var energyLevel:[energyLevel_allergies]?
	var headache:[headache_allergies]?
}
*/


/*
class AllergyEntry: NSObject {

	var date:Date
	var allergies:AllergyResponse
	
	func dictionary() -> [String:[String]]{
		var d:[String:[String]] = [:]
		if let y = allergies.eyes{ d["eyes"]=[String](); for z in y{d["eyes"]!.append(z.rawValue)} }
		if let y = allergies.sinus{ d["sinus"]=[String](); for z in y{d["sinus"]!.append(z.rawValue)} }
		if let y = allergies.nose{ d["nose"]=[String](); for z in y{d["nose"]!.append(z.rawValue)} }
		if let y = allergies.throat{ d["throat"]=[String](); for z in y{d["throat"]!.append(z.rawValue)} }
		if let y = allergies.lungs{ d["lungs"]=[String](); for z in y{d["lungs"]!.append(z.rawValue)} }
		if let y = allergies.skin{ d["skin"]=[String](); for z in y{d["skin"]!.append(z.rawValue)} }
		if let y = allergies.meds{ d["meds"]=[String](); for z in y{d["meds"]!.append(z.rawValue)} }
		if let y = allergies.wokeUp{ d["woke up"]=[String](); for z in y{d["woke up"]!.append(z.rawValue)} }
		if let y = allergies.nightTime{ d["night time"]=[String](); for z in y{d["night time"]!.append(z.rawValue)} }
		if let y = allergies.pet{ d["pet"]=[String](); for z in y{d["pet"]!.append(z.rawValue)} }
		if let y = allergies.mold{ d["mold"]=[String](); for z in y{d["mold"]!.append(z.rawValue)} }
		if let y = allergies.dust{ d["dust"]=[String](); for z in y{d["dust"]!.append(z.rawValue)} }
		if let y = allergies.outdoors{ d["outdoors"]=[String](); for z in y{d["outdoors"]!.append(z.rawValue)} }
		if let y = allergies.energyLevel{ d["energy level"]=[String](); for z in y{d["energy level"]!.append(z.rawValue)} }
		if let y = allergies.headache{ d["headache"]=[String](); for z in y{d["headache"]!.append(z.rawValue)} }
		return d
	}
	
	func setFromDictionary( d:[String:[String]], date:Date ) {
		self.date = date
		var a = AllergyResponse()
		for (key,value) in d{
			switch key{
			case "eyes":
				if a.eyes==nil{a.eyes=[];}
				for v in value{
					if let e=eyes_allergies.init(rawValue:v){
						a.eyes!.append(e)
					}
				}
				
			case "eyes": a.eyes=[]; for v in value{if let e=eyes_allergies.init(rawValue:v){a.eyes!.append(e)} }
			case "sinus": a.sinus=[]; for v in value{if let e=sinus_allergies.init(rawValue:v){a.sinus!.append(e)} }
			case "nose": a.nose=[]; for v in value{if let e=nose_allergies.init(rawValue:v){a.nose!.append(e)} }
			case "throat": a.throat=[]; for v in value{if let e=throat_allergies.init(rawValue:v){a.throat!.append(e)} }
			case "lungs": a.lungs=[]; for v in value{if let e=lungs_allergies.init(rawValue:v){a.lungs!.append(e)} }
			case "skin": a.skin=[]; for v in value{if let e=skin_allergies.init(rawValue:v){a.skin!.append(e)} }
			case "meds": a.meds=[]; for v in value{if let e=meds_allergies.init(rawValue:v){a.meds!.append(e)} }
			case "woke up": a.wokeUp=[]; for v in value{if let e=wokeUp_allergies.init(rawValue:v){a.wokeUp!.append(e)} }
			case "night time": a.nightTime=[]; for v in value{if let e=nightTime_allergies.init(rawValue:v){a.nightTime!.append(e)} }
			case "pet": a.pet=[]; for v in value{if let e=pet_allergies.init(rawValue:v){a.pet!.append(e)} }
			case "mold": a.mold=[]; for v in value{if let e=mold_allergies.init(rawValue:v){a.mold!.append(e)} }
			case "dust": a.dust=[]; for v in value{if let e=dust_allergies.init(rawValue:v){a.dust!.append(e)} }
			case "outdoors": a.outdoors=[]; for v in value{if let e=outdoors_allergies.init(rawValue:v){a.outdoors!.append(e)} }
			case "energy level": a.energyLevel=[]; for v in value{if let e=energyLevel_allergies.init(rawValue:v){a.energyLevel!.append(e)} }
			case "headache": a.headache=[]; for v in value{if let e=headache_allergies.init(rawValue:v){a.headache!.append(e)} }
			default: break
			}
		}
	}

	override init() {
		// dates are initialized to NOW time, in user's time zone
		self.date = Date()
		self.allergies = AllergyResponse()
		super.init()
	}

	func log(){
//		print(self.values)
	}

}
*/



//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let USER_DEFAULTS_MY_ALLERGY_TYPES = "allergies"
let USER_DEFAULTS_SORT_PLANT_PREFERENCE = "sortAllergiesBy"
let USER_DEFAULTS_PUSH_NOTIFICATION_TYPES = "notifications"


struct ClinicHours{
	var days:String  // days is something like "M-F"
	var times:String  // times is something like "8am - 5pm"
	init(withDictionary dictionary:[String:AnyObject]){
		days = dictionary["days"] as? String ?? ""
		times = dictionary["times"] as? String ?? ""
	}
}

struct ClinicInfo{
	var address:String
	var phone:String
	var website:String
	var hours:[ClinicHours]
	init(withDictionary dictionary:[String:AnyObject]){
		address = dictionary["address"] as? String ?? ""
		phone = dictionary["phone"] as? String ?? ""
		website = dictionary["website"] as? String ?? ""
		hours = (dictionary["hours"] as? Array ?? []).map({ return ClinicHours(withDictionary: $0) })
	}
}

enum PollenTypeSeason:Int{
	case spring
	case summer
	case autumn
	case winter
	func asString() -> String {
		switch self{
		case .spring: return "spring"
		case .summer: return "summer"
		case .autumn: return "autumn"
		case .winter: return "winter"
		}
	}
}
enum PollenTypeGroup:Int{
	case trees
	case grasses
	case molds
	case weeds
	func asString() -> String {
		switch self{
		case .trees: return "trees"
		case .grasses: return "grasses"
		case .molds: return "molds"
		case .weeds: return "weeds"
		}
	}
}
struct PollenTypeLevels{
	var l:Int
	var m:Int
	var h:Int
	var vh:Int
	init(withDictionary dictionary:[String:Int]){
		l = dictionary["l"] ?? 15
		m = dictionary["m"] ?? 50
		h = dictionary["h"] ?? 300
		vh = dictionary["vh"] ?? 3000
	}
}
struct PollenType{
	var key:String
	var name:String
	var season:PollenTypeSeason
	var group:PollenTypeGroup
	var levels:PollenTypeLevels
	func logValue(forValue value:Int) -> Float {
		var result = Float(value) / Float(levels.vh)
		if(result > 1.0){ result = 1.0 }
		result = pow(result, 0.1)
		result = result - 0.5;
		if(result < 0.0){ result = 0.0 }
		result *= 2
		return result
	}
	func rating(forValue value:Int) -> Rating{
		if value < levels.l{ return .none }
		if value < levels.m{ return .low }
		if value < levels.h{ return .medium }
		if value < levels.vh{ return .heavy }
		return .veryHeavy
	}
}

class Pollen {

	static let shared = Pollen()
	
	// fill on boot
	var types:[PollenType] = []
	
	var clinic:ClinicInfo?

	// this is a mirror of the "types" entry in the database
	// keys are abbreviation of pollen names, values are dictionaries
	var notifications:[String:Any] = [:]{
		// "enabled": BOOL
		// "level": 0,1,2,3 (none, low, med, heavy, very heavy)
		didSet{
			UserDefaults.standard.setValue(self.notifications, forKey: USER_DEFAULTS_PUSH_NOTIFICATION_TYPES)
		}
	}
	
	// whether the user is allergic to a certain plant: keys are pollen-keys, values are T/F
	var myAllergies:[String:Bool] = [:]{
		didSet{
			UserDefaults.standard.setValue(self.myAllergies, forKey: USER_DEFAULTS_MY_ALLERGY_TYPES)
		}
	}
	
	var sortAllergiesBy:Int = 0{  // on my allergies page, sort by season / group
		didSet{
			UserDefaults.standard.setValue(self.sortAllergiesBy, forKey: USER_DEFAULTS_SORT_PLANT_PREFERENCE)
		}
	}
	
	func loadSystemPList(){
		guard let plistPath = Bundle.main.path(forResource: "Pollen", ofType: "plist") else { return }
		guard let plistData = FileManager.default.contents(atPath: plistPath) else {return}
		var format = PropertyListSerialization.PropertyListFormat.xml
		guard let pListDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String:AnyObject] else {return}
		
		if let clinicDict = pListDict["clinic"] as? [String:AnyObject]{
			self.clinic = ClinicInfo(withDictionary: clinicDict)
		}

		if let typesDict = pListDict["types"] as? [[String:AnyObject]]{
			self.types = typesDict.map { (entry) -> PollenType in
				let typeName = entry["name"] as? String ?? ""
				let typeKey = entry["key"] as? String ?? ""
				let typeSeason = PollenTypeSeason(rawValue: (entry["season"] as? Int ?? 0))!
				let typeGroup = PollenTypeGroup(rawValue: (entry["group"] as? Int ?? 0))!
				let typeLevels = PollenTypeLevels(withDictionary: entry["levels"] as? [String:Int] ?? [:])
				return PollenType(key: typeKey, name: typeName, season: typeSeason, group: typeGroup, levels: typeLevels)
			}
			
			print(self.types)

//			if let types = data.value as? [String:Any]{
//				self.types = types
//				self.refreshUserDefaults()
//				if(completionHandler != nil){
//					completionHandler!(true)
//				}
//			}

		}
	}

	func boot(completionHandler: ((_ success:Bool) -> ())? ){
//		FirebaseApp.configure()
//		Database.database().reference().child("types").observeSingleEvent(of: .value) { (data: DataSnapshot) in
//			if let types = data.value as? [String:Any]{
//				self.types = types
//				self.refreshUserDefaults()
//				if(completionHandler != nil){
//					completionHandler!(true)
//				}
//			}
//		}

		
		// get pollen types
		loadSystemPList()

		self.bootUserDefaults()
		if(completionHandler != nil){
			completionHandler!(true)
		}
	}
	
//	func getValueFor(key:String, atRating:Rating) -> Int{
//		let pollenType:[String:Any] = self.types[key] as! [String : Any]
//		if let levels = pollenType["levels"] as? [String:Any]{
//			switch atRating{
//			case .none: return 0
//			case .low: return levels["l"] as! Int
//			case .medium: return levels["m"] as! Int
//			case .heavy: return levels["h"] as! Int
//			case .veryHeavy: return levels["vh"] as! Int
//			}
//		}
//		return 0
//	}
	
	func nameFor(key:String) -> String{
		if let validMatch = self.types.filter({ $0.key == key }).first{ return validMatch.name }
		return key
	}

	func logValueFor(key:String, value:Int) -> Float{
		if let validMatch = self.types.filter({ $0.key == key }).first{
			return validMatch.logValue(forValue: value)
		}
		return 0.0
	}
	
	func ratingFor(key:String, value:Int) -> Rating{
		if let validMatch = self.types.filter({ $0.key == key }).first{
			return validMatch.rating(forValue: value)
		}
		return .none
	}
	
	func bootUserDefaults(){
		// my allergy types
		if let storedAllergies = UserDefaults.standard.object(forKey:USER_DEFAULTS_MY_ALLERGY_TYPES) as? [String:Bool]{
			// boot up allergies from last storage
			self.myAllergies = storedAllergies;
			// make sure all keys are inside our defaults in case new plants have been added since last run
			self.types.map({ $0.key }).forEach({
				if self.myAllergies[$0] == nil{
					self.myAllergies[$0] = true
				}
			})
		} else{
			// first boot. fill all allergy types with key:true
			self.myAllergies = self.types.reduce(into: [:]) { $0[$1.key] = true }
		}
		
		// push notification preferences
		self.notifications = UserDefaults.standard.object(forKey:USER_DEFAULTS_PUSH_NOTIFICATION_TYPES) as? [String:Any] ?? [:]
		if (self.notifications["enabled"] == nil){ self.notifications["enabled"] = true }
		if (self.notifications["level"] == nil){ self.notifications["level"] = 2 }

		// preferences pane, sort allergy by
		self.sortAllergiesBy = UserDefaults.standard.object(forKey:USER_DEFAULTS_SORT_PLANT_PREFERENCE) as? Int ?? 0
	}

}

//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

let USER_DEFAULTS_MY_ALLERGY_TYPES = "allergies"
let USER_DEFAULTS_SORT_PLANT_PREFERENCE = "sortAllergiesBy"
let USER_DEFAULTS_PUSH_NOTIFICATION_TYPES = "notifications"
let USER_DEFAULTS_HAS_SEEN_CHARTS = "has-seen-charts"
let USER_DEFAULTS_HAS_SEEN_CHARTS_HINT = "has-seen-charts-hint"

class Pollen {

	static let shared = Pollen()
	
	// fill on boot
	var types:[PollenType] = []
	var clinic:ClinicInfo?

	fileprivate init(){
		loadSystemPList()
		bootUserDefaults()
	}
	
	var hasSeenCharts = false{
		didSet{ UserDefaults.standard.set(hasSeenCharts, forKey: USER_DEFAULTS_HAS_SEEN_CHARTS) }
	}
//	var hasSeenChartsHint = false{
//		didSet{ UserDefaults.standard.set(hasSeenChartsHint, forKey: USER_DEFAULTS_HAS_SEEN_CHARTS_HINT) }
//	}

	// this is a mirror of the "types" entry in the database
	// keys are abbreviation of pollen names, values are dictionaries
	var notifications:[String:Any] = [:]{
		// "enabled": BOOL
		// "level": 0,1,2,3 (none, low, med, heavy, very heavy)
		didSet{ UserDefaults.standard.setValue(self.notifications, forKey: USER_DEFAULTS_PUSH_NOTIFICATION_TYPES) }
	}
	
	// whether the user is allergic to a certain plant: keys are pollen-keys, values are T/F
	var myAllergies:[String:Bool] = [:]{
		didSet{ UserDefaults.standard.setValue(self.myAllergies, forKey: USER_DEFAULTS_MY_ALLERGY_TYPES) }
	}
	
	var sortAllergiesBy:Int = 0{  // on my allergies page, sort by season / group
		didSet{ UserDefaults.standard.setValue(self.sortAllergiesBy, forKey: USER_DEFAULTS_SORT_PLANT_PREFERENCE) }
	}
	
	func nameFor(key:String) -> String{
		if let validMatch = self.types.filter({ $0.key == key }).first{ return validMatch.name }
		return key
	}

	func loadSystemPList(){
		func pListBootError(){ print("plist is corrupt. app bundle directory has been modified.") }
		guard let plistPath = Bundle.main.path(forResource: "Pollen", ofType: "plist") else { pListBootError(); return }
		guard let plistData = FileManager.default.contents(atPath: plistPath) else { pListBootError(); return }
		var format = PropertyListSerialization.PropertyListFormat.xml
		guard let pListDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String:AnyObject] else { pListBootError(); return }
		
		guard let clinicDictionary = pListDict["clinic"] as? [String:AnyObject] else { pListBootError(); return }
		self.clinic = ClinicInfo(withDictionary: clinicDictionary)
		
		guard let typesDictionary = pListDict["types"] as? [[String:AnyObject]] else { pListBootError(); return }
		self.types = typesDictionary.map { (entry) -> PollenType in
			let typeName = entry["name"] as? String ?? ""
			let typeKey = entry["key"] as? String ?? ""
			let typeSeason = PollenTypeSeason(rawValue: (entry["season"] as? Int ?? 0))!
			let typeGroup = PollenTypeGroup(rawValue: (entry["group"] as? Int ?? 0))!
			let typeLevels = PollenTypeLevels(withDictionary: entry["levels"] as? [String:Int] ?? [:])
			return PollenType(key: typeKey, name: typeName, season: typeSeason, group: typeGroup, levels: typeLevels)
		}
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

		
		// has seen the charts hint notification
		if let seenCharts = UserDefaults.standard.object(forKey:USER_DEFAULTS_HAS_SEEN_CHARTS) as? Bool{
			hasSeenCharts = seenCharts
		} else{
			hasSeenCharts = false
		}
//		if let seenChartsHint = UserDefaults.standard.object(forKey:USER_DEFAULTS_HAS_SEEN_CHARTS_HINT) as? Bool{
//			hasSeenChartsHint = seenChartsHint
//		} else{
//			hasSeenChartsHint = false
//		}

	}
	
}

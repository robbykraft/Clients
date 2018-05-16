//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum Rating {
	case none
	case low
	case medium
	case heavy
	case veryHeavy
}

struct PollenLevels{
	var vh:Int
	var h:Int
	var m:Int
	var l:Int
}

struct PollenType{
	var name:String
	var levels:PollenLevels
	var group:Int
	var season:Int
}

class Pollen {

	static let shared = Pollen()
	
	// fill on boot
	var types:[String:Any] = [:]
	// this is a mirror of the "types" entry in the database
	// keys are abbreviation of pollen names, values are dictionaries
	
	var notifications:[String:Any] = [:]{
		// "enabled": BOOL
		// "level: 0,1,2,3 (none, low, med, heavy, very heavy)
		didSet{
			let defaults = UserDefaults.standard
			defaults.setValue(self.notifications, forKey: "notifications")
		}
	}
	
	var myAllergies:[String:Bool] = [:]{
		// pollen-key, T/F
		didSet{
			let defaults = UserDefaults.standard
			defaults.setValue(self.myAllergies, forKey: "allergies")
		}
	}
	
	var sortAllergiesBy:Int = 0{  // on my allergies page, sort by season / group
		didSet{
			let defaults = UserDefaults.standard
			defaults.setValue(self.sortAllergiesBy, forKey: "sortAllergiesBy")
		}
	}
		
	
	func boot(completionHandler: ((_ success:Bool) -> ())? ){
		// get pollen types
		Database.database().reference().child("types").observeSingleEvent(of: .value) { (data: DataSnapshot) in
			if let types = data.value as? [String:Any]{
				self.types = types
				self.refreshUserDefaults()
				if(completionHandler != nil){
					completionHandler!(true)
				}
			}
		}
	}
	
	func getValueFor(key:String, atRating:Rating) -> Int{
		let pollenType:[String:Any] = self.types[key] as! [String : Any]
		if let levels = pollenType["levels"] as? [String:Any]{
			switch atRating{
			case .none: return 0
			case .low: return levels["l"] as! Int
			case .medium: return levels["m"] as! Int
			case .heavy: return levels["h"] as! Int
			case .veryHeavy: return levels["vh"] as! Int
			}
		}
		return 0
	}
	
	func nameFor(key:String) -> String{
		let entry = self.types[key] as? [String:Any]
		if let e = entry{
			let name = e["name"] as? String
			if let n = name{
				return n
			}
		}
		return key
	}

	func logValueFor(key:String, value:Int) -> Float{
		let pollenType:[String:Any] = self.types[key] as! [String : Any]
		if let levels = pollenType["levels"] as? [String:Any]{
			let veryHeavy:Int = levels["vh"] as! Int
			var result = Float(value) / Float(veryHeavy)
			if(result > 1.0){ result = 1.0 }
			result = pow(result, 0.1)
			result = result - 0.5;
			if(result < 0.0) {result = 0.0}
			result *= 2
			return result
		}
		return 0.0
	}
	
	func ratingFor(key:String, value:Int) -> Rating{
		let pollenType:[String:Any] = self.types[key] as! [String : Any]
		if let levels = pollenType["levels"] as? [String:Any]{
			let low:Int = levels["l"] as! Int
			let med:Int = levels["m"] as! Int
			let heavy:Int = levels["h"] as! Int
			let veryHeavy:Int = levels["vh"] as! Int
			if value < low{ return .none }
			if value < med{ return .low }
			if value < heavy{ return .medium }
			if value < veryHeavy{ return .heavy }
			return .veryHeavy
		}
		return .none
	}
	
	
	func refreshUserDefaults(){
		let defaults = UserDefaults.standard
		// allergies
		if var allergies = defaults.object(forKey:"allergies") as? [String:Bool] {
			let keys:[String] = Array(self.types.keys)
			for key in keys{
				if(allergies[key] == nil){
					print("adding an allergy entry for " + key)
					allergies[key] = true
				}
			}
			self.myAllergies = allergies
		} else{
			let keys:[String] = Array(self.types.keys)
			var emptyAllergies:[String:Bool] = [:]
			for key in keys{
				emptyAllergies[key] = true
			}
			self.myAllergies = emptyAllergies
		}
		// push notification preferences
		if var pnPrefs = defaults.object(forKey:"notifications") as? [String:Any] {
			if (pnPrefs["enabled"] == nil){
				pnPrefs["enabled"] = true
			}
			if (pnPrefs["level"] == nil){
				pnPrefs["level"] = 2
			}
			self.notifications = pnPrefs
		} else{
			let pnPrefs:[String:Any] = [
				"enabled" : true,
				"level" : 2
				]
			self.notifications = pnPrefs
		}
		if let mySort = defaults.object(forKey:"sortAllergiesBy") as? Int {
			self.sortAllergiesBy = mySort
		} else{
			self.sortAllergiesBy = 0
		}
		print("refreshUserDefaults did finish")
		
	}
	
	func stringForRating(_ rating:Rating) -> String{
		switch rating {
		case .veryHeavy: return "very heavy"
		case .heavy: return "heavy"
		case .medium: return "medium"
		case .low: return "light"
		case .none: return "no pollen"
		}
	}
	
//	func getPollenTypes(completionHandler: ((_ success:Bool) -> ())? ){
//		Fire.shared.getData("types") { (data) in
//			if let types = data as? [String:Any]{
//				self.types = types
//				if(completionHandler != nil){
//					completionHandler!(true)
//				}
//			}
//		}
//	}
	
	func getAllPollenNames() -> [String]{
		var nameArray:[String] = [];
		let keys = Array(self.types.keys)
		for key in keys{
			if let thisType = self.types[key] as? [String:Any]{
				if let thisName = thisType["name"] as? String{
					nameArray.append(thisName)
				}
			}
		}
		return nameArray
	}
	
	
//	func loadRecentData(numberOfDays:Int, completionHandler: ((_ entry:PollenSample) -> ())? ){
//		
//		var tries = 0
//		var successes = 0
//		func queryDatabase(){
//			let dateString = makeDateCode(daysPast: tries)
//			tries += 1
//			Fire.shared.getData("collections/" + dateString) { (data) in
//				if(data == nil && tries < 40){
//					print("no entry for " + dateString + ". trying again")
//					queryDatabase()
//				} else if let d = data as? [String:Any]{
//					let sample = Sample()
//					sample.setFromDatabase(d)
//					if(completionHandler != nil){
//						completionHandler!(sample)
//					}
//					successes += 1
//					if successes < numberOfDays{
//						queryDatabase()
//					}
//				}
//			}
//		}
//		
//		// run the function
//		queryDatabase()
//	}

}

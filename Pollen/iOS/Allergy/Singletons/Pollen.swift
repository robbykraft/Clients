//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation
import SQLite

enum Rating {
	case none
	case low
	case medium
	case heavy
	case veryHeavy
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
	
	func sqliteThings(){
		var databasePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		databasePath.append("/db.sqlite3")
		print(databasePath)
		if let db = try? Connection(databasePath){
			let dailies = Table("dalies")
			do{
				let id = Expression<Int64>("id")
				let year = Expression<Int64>("year")
				let month = Expression<Int64>("month")
				let day = Expression<Int64>("day")
				
				try db.run(dailies.create(block: { (t) in
					t.column(id, primaryKey: true)
					t.column(year)
					t.column(month)
					t.column(day)
					for key in AllergyConditionsKeys{
						let allergyCondition = Expression<Int64>(key)
						t.column(allergyCondition)
					}
				}))
				
//				let insert2 = dailies.insert(name <- "franklin", year <- )
				
				// UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
				// WHERE ("id" = 1)
				print("success creating db")
				// INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
				
				
			} catch{
				print("catch fail")
			}
			
			do{
				let year = Expression<Int64>("year")
				let month = Expression<Int64>("month")
				let day = Expression<Int64>("day")
				let insert = dailies.insert(year <- 2017, month <- 12, day <- 15)
				let rowid = try db.run(insert)
				
//				let alice = users.filter(id == rowid)
				for key in AllergyConditionsKeys{
					let allergyCondition = Expression<Int64>(key)
					let value:Int64 = 2
					try db.run(dailies.update(allergyCondition <- value))
				}
				print("update new entry success")
				print(rowid)
			} catch{
				print("update new entry fail")
			}
		}
	}
	
	
	func boot(completionHandler: ((_ success:Bool) -> ())? ){
		self.getPollenTypes { (success) in
			if(success){
				self.refreshUserDefaults()
				if(completionHandler != nil){
					print("calling boot() completion handler")
					completionHandler!(true)
				}
			} else{
				// throw an error
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
	
	func getPollenTypes(completionHandler: ((_ success:Bool) -> ())? ){
		Fire.shared.getData("types") { (data) in
			if let types = data as? [String:Any]{
				self.types = types
				if(completionHandler != nil){
					completionHandler!(true)
				}
			}
		}
	}
	
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
	
	// daysPast is expecting a positive number. ("5" means 5 days ago)
	func makeDateCode(daysPast:Int) -> String{
//		var GMTCalendar = Calendar.current
//		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		var deltaDate = DateComponents()
		deltaDate.day = -daysPast
		let dateIterate:Date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: Date(), options: NSCalendar.Options.matchFirst)!
		
		let yearNumber:Int = Calendar.current.component(.year, from: dateIterate)
		let monthNumber:Int = Calendar.current.component(.month, from: dateIterate)
		let dayNumber:Int = Calendar.current.component(.day, from: dateIterate)
		return "\(yearNumber)" + String(format: "%02d", monthNumber) + String(format: "%02d", dayNumber)
	}
	
	func loadRecentData(numberOfDays:Int, completionHandler: ((_ entry:Sample) -> ())? ){
		
		var tries = 0
		var successes = 0
		func queryDatabase(){
			let dateString = makeDateCode(daysPast: tries)
			tries += 1
			Fire.shared.getData("collections/" + dateString) { (data) in
				if(data == nil && tries < 40){
					print("no entry for " + dateString + ". trying again")
					queryDatabase()
				} else if let d = data as? [String:Any]{
					let sample = Sample()
					sample.setFromDatabase(d)
					if(completionHandler != nil){
						completionHandler!(sample)
					}
					successes += 1
					if successes < numberOfDays{
						queryDatabase()
					}
				}
			}
		}
		
		// run the function
		queryDatabase()
	}

}

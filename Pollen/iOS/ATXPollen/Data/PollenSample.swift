//
//  PollenSample.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

enum Rating: Int{
	case none
	case low
	case medium
	case heavy
	case veryHeavy
	
	func description() -> String {
		switch self {
		case .none: return "no pollen"
		case .low: return "low"
		case .medium: return "medium"
		case .heavy: return "heavy"
		case .veryHeavy: return "very heavy"
		}
	}
}

struct PollenSamples {
	
	var date:Date?
	var values:[String:Int] = [:]

	/** default initializer. fill with contents from firebase database. this is expecting:
	* key "counts" with array of values ["pollen key":Int]
	* key "date" with a unix timestamp
	*/
	init(fromDatabase data:[String:Any]){
		guard let unixDate = data["date"] as? Double else {return}
		guard let counts = data["counts"] as? [String:Any] else { return }
		// expecting database to store INT types. if not it is implied the string value "t" means trace and is stored as 0
		self.values = counts.mapValues { (value:Any) -> Int in
			return value is Int ? value as! Int : 0
		}
		self.date = Date.init(timeIntervalSince1970: unixDate)
	}

	/** returns the highest Rating of pollen entries in values */
	func rating() -> Rating{
		return values
			.map{ return Pollen.shared.ratingFor(key: $0, value: $1) }
			.reduce(.none) { (a:Rating, b:Rating) -> Rating in
				return (a.rawValue > b.rawValue) ? a : b
		}
	}
	
	// my report gives back the sample, filtered through your curated list of allergy types
	//
	func report() -> [(String, Int, Float, Rating)]{  // name, raw value, 0.0-1.0 log value, Rating(low,high)
		var report:[(String, Int, Float, Rating)] = []
		for key in Array(self.values.keys) {
			if Pollen.shared.myAllergies[key]!{
				report.append( (Pollen.shared.nameFor(key: key), self.values[key]!, Pollen.shared.logValueFor(key: key, value: self.values[key]!), Pollen.shared.ratingFor(key: key, value: self.values[key]! ) ) )
			}
		}
		return report
	}
	
}

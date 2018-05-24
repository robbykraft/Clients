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

struct PollenSample{
	var key:String
	var value:Int
	var rating:Rating
	var name:String
	var logValue:Float
	
	init(withKey key:String, value:Int){
		self.key = key
		self.value = value
		self.rating = Pollen.shared.ratingFor(key: key, value: value)
		self.name = Pollen.shared.nameFor(key: key)
		self.logValue = Pollen.shared.logValueFor(key: key, value: value)
	}
}

struct PollenSamples {
	
	var date:Date?
	// ask for relevantSamples() instead. it filters through your list of personal allergies
	private var samples:[PollenSample] = []

	/** default initializer. fill with contents from firebase database. this is expecting:
	* key "counts" with array of values ["pollen key":Int]
	* key "date" with a unix timestamp
	*/
	init(fromDatabase data:[String:Any]){
		guard let unixDate = data["date"] as? Double else {return}
		guard let counts = data["counts"] as? [String:Any] else { return }
		// expecting database to store INT types. if not it is implied the string value "t" means trace and is stored as 0
		self.samples = counts.map({ (key, value) -> PollenSample in
			return PollenSample(withKey: key, value: value is Int ? value as! Int : 0)
		})
		self.date = Date.init(timeIntervalSince1970: unixDate)
	}

	/** returns the highest Rating of pollen entries filtered through your curated list of allergy types */
	func rating() -> Rating{
		return self.relevantSamples()
			.map({ $0.rating })
			.sorted(by: { $0.rawValue > $1.rawValue })
			.first ?? .none
	}
	
	/** my get back the array of samples filtered through your curated list of allergy types */
	func relevantSamples() -> [PollenSample]{
		return self.samples.filter({ (sample) -> Bool in
			return Pollen.shared.myAllergies[sample.key] ?? true
		})
	}

}

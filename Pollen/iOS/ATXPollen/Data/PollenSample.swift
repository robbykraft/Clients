//
//  PollenSample.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

struct PollenSample{
	var type:PollenType
	var rating:PollenRating
	var value:Int
	var logValue:Float
	
	init(withKey key:String, value:Int){
		var group:PollenTypeGroup
		var season:PollenTypeSeason
		var levels:PollenTypeLevels
		if let typematch = Pollen.shared.types.filter({$0.key == key}).first{
			group = typematch.group
			season = typematch.season
			levels = typematch.levels
		} else{
			group = .grasses
			season = .spring
			levels = PollenTypeLevels(withDictionary: [:])
		}
		self.type = PollenType(key: key, name: Pollen.shared.nameFor(key: key), season: season, group: group, levels: levels)
		self.value = value
		self.logValue = self.type.logValue(forValue: value)
		self.rating = self.type.rating(forValue: value)
	}
}

struct PollenSamples {
	// make sure to use relevantToMyAllergies(). it filters through your list of personal allergies

	var date:Date?
	private var samples:[PollenSample] = []
	
	func getSamples() -> [PollenSample] { return samples }

	/** default initializer. fill with contents from firebase database. this is expecting:
	* key "counts" with array of values ["pollen key":Int]
	* key "date" with a unix timestamp
	*/
	init(fromDatabase data:[String:Any]){
		guard let unixDate = data["date"] as? Double else {return}
		self.date = Date.init(timeIntervalSince1970: unixDate)
		if let counts = data["counts"] as? [String:Any]{
			// expecting database to store INT types. if not it is implied the string value "t" means trace and is stored as 0
			self.samples = counts.map({ (key, value) -> PollenSample in
				return PollenSample(withKey: key, value: value is Int ? value as! Int : 0)
			})
		}
	}
	
	func strongestSample() -> PollenSample?{
		return self.samples
			.sorted(by: { $0.logValue > $1.logValue })
			.first
	}

	/** returns the highest PollenRating of pollen entries filtered through your curated list of allergy types */
	func rating() -> PollenRating{
		return self.samples
			.map({ $0.rating })
			.sorted(by: { $0.rawValue > $1.rawValue })
			.first ?? .none
	}
	
	func filteredBy(group:PollenTypeGroup) -> PollenSamples{
		var samples = PollenSamples(fromDatabase: [:])
		samples.date = self.date
		samples.samples = self.samples.filter({ $0.type.group == group })
		return samples
	}
	
	/** my get back a copy of this with samples filtered through your curated list of allergy types */
	func relevantToMyAllergies() -> PollenSamples{
		var samples = PollenSamples(fromDatabase: [:])
		samples.date = self.date
		samples.samples = self.samples.filter({ (sample) -> Bool in
			return Pollen.shared.myAllergies[sample.type.key] ?? true
		})
		return samples
	}

}

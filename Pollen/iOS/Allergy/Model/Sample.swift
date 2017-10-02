//
//  Sample.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class Sample: NSObject {
	
	var date:Date?
	
	var values:[String:Int] = [:]
	
	func setFromDatabase(_ data:[String:Any]){
		if let counts = data["counts"] as? [String:Any]{
			for item in Array(counts.keys) {
				if let itemValue = counts[item]{
					var v:Int?
					if let valueInt = itemValue as? Int{
						v = valueInt
					} else if itemValue is String{
//						v = -1
						// big question here, should we report trace amounts, or
						// count them the same as an unread sample.
						// remember this is just for the public
					}
					if let value = v{
						self.values[item] = value
					}
				}
			}
		}
		if let unixTime = data["date"] as? Double{
			self.date = Date.init(timeIntervalSince1970: unixTime)
		}
	}
	
	func generateSummary() -> Rating{
		var ratings:[Rating] = []
		for key in Array(self.values.keys) {
			if Pollen.shared.myAllergies[key]!{
				ratings.append(Pollen.shared.ratingFor(key: key, value: self.values[key]!))
			}
		}
		if(ratings.contains(.veryHeavy)){ return .veryHeavy }
		if(ratings.contains(.heavy)){ return .heavy }
		if(ratings.contains(.medium)){ return .medium }
		if(ratings.contains(.low)){ return .low }
		return .none
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
	
	func log(){
		print(self.values)
	}

	
}

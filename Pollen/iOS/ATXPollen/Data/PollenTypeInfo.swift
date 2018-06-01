//
//  PollenTypeInfo.swift
//  ATXPollen
//
//  Created by Robby Kraft on 5/26/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation

enum PollenRating: Int{
	case none
	case low
	case medium
	case heavy
	case veryHeavy
	
	func asString() -> String {
		switch self {
		case .none: return "no pollen"
		case .low: return "low"
		case .medium: return "medium"
		case .heavy: return "heavy"
		case .veryHeavy: return "very heavy"
		}
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
	func rating(forValue value:Int) -> PollenRating{
		if value < levels.l{ return .none }
		if value < levels.m{ return .low }
		if value < levels.h{ return .medium }
		if value < levels.vh{ return .heavy }
		return .veryHeavy
	}
}

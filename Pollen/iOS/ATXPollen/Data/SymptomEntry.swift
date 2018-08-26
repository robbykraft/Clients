//
//  SymptomSample.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/6/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation

enum SymptomRating : Int{
	case none
	case light
	case medium
	case severe
	func asString() -> String {
		switch self {
		case .none: return "no allergies"
		case .light: return "light"
		case .medium: return "medium"
		case .severe: return "severe"
		}
	}
}

enum Exposures : Int { // CaseIterable // next version of swift
	case dog
	case cat
	case dust
	case molds
	case virus
	func asString() -> String{
		switch self{
		case .dog: return "dog"
		case .cat: return "cat"
		case .dust: return "dust"
		case .molds: return "molds"
		case .virus: return "virus"
		}
	}
}

// weird global function
// used when pulling exposures (strings) out of the database
func exposureFromString(string:String) -> Exposures?{
	switch string{
	case "dog": return .dog
	case "cat": return .cat
	case "molds": return .molds
	case "dust": return .dust
	case "virus": return .virus
	default: return nil
	}
}

struct SymptomEntry{
	var date:Date
	var location:(Double, Double)?
	var rating:SymptomRating?
	var exposures:[Exposures]?
}


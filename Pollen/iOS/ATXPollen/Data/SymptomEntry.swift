//
//  SymptomSample.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/6/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation

enum SymptomRating: Int{
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

enum Exposures{
	case dog
	case cat
	case molds
	case dust
	case virus
	func asString() -> String{
		switch self{
		case .dog: return "dog"
		case .cat: return "cat"
		case .molds: return "molds"
		case .dust: return "dust"
		case .virus: return "virus"
		}
	}
}

struct SymptomEntry{
	var date:Date
	var location:(Double, Double)?
	var rating:SymptomRating?
	var exposures:[Exposures]?
}


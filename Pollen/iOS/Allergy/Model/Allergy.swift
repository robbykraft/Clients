//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 11/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

let AllergyConditionsKeys = ["eyes_itchy", "eyes_red", "eyes_watery", "eyes_bags", "sinus_pressure", "sinus_pain", "sinus_coloredDischarge", "sinus_toothPain", "nose_stuffy", "nose_itchy", "nose_runny", "nose_blood", "throat_clearing", "throat_sore", "throat_hoarseVoice", "throat_itchyScratchy", "lungs_wheeze", "lungs_cough", "lungs_tightChest", "lungs_shortBreath", "skin_itch", "skin_bumpsHives", "skin_eczema", "skin_swelling", "meds_pill", "meds_noseSpray", "meds_inhaler", "meds_topicalCream", "wokeUp_groggyHead", "wokeUp_stuffedUp", "wokeUp_CrustyEyes", "wokeUp_dryLips", "nightTime_stuffy", "nightTime_cough", "nightTime_throatDrainage", "nightTime_wheezeChest", "pet_dog", "pet_cat", "pet_rodent", "pet_horse", "mold_home", "mold_work", "mold_school", "mold_other", "dust_home", "dust_work", "dust_school", "dust_other", "outdoors_playingSports", "outdoors_airTravel", "outdoors_someoneSick", "outdoors_airPollution", "energyLevel_great", "energyLevel_medium", "energyLevel_low", "energyLevel_sick", "headache_forehead", "headache_sides", "headache_back", "headache_behindEyes"]

let bodyParts = [
	"eyes",
	"sinus",
	"nose",
	"throat",
	"lungs",
	"skin",
	"meds",
	"wokeUp",
	"nightTime",
	"pet",
	"mold",
	"dust",
	"outdoors",
	"energyLevel",
	"headache"
]

let symptoms = [
	["itchy", "red", "watery", "bags"],								// eyes
	["pressure", "pain", "coloredDischarge", "toothPain"],			// sinus
	["stuffy", "itchy", "runny", "blood"],							// nose
	["clearing", "sore", "hoarseVoice", "itchyScratchy"],			// throat
	["wheeze", "cough", "tightChest", "shortBreath"],				// lungs
	["itch", "bumpsHives", "eczema", "swelling"],					// skin
	["pill", "noseSpray", "inhaler", "topicalCream"],				// meds
	["groggyHead", "stuffedUp", "CrustyEyes", "dryLips"],			// wokeUp
	["stuffy", "cough", "throatDrainage", "wheezeChest"],			// nightTime
	["dog", "cat", "rodent", "horse"],								// pet
	["home", "work", "school", "other"],							// mold
	["home", "work", "school", "other"],							// dust
	["playingSports", "airTravel", "someoneSick", "airPollution"],	// outdoors
	["great", "medium", "low", "sick"],								// energyLevel
	["forehead", "sides", "back", "behindEyes"]						// headache
]

enum AllergyConditions:String {
	case eyes_itchy
	case eyes_red
	case eyes_watery
	case eyes_bags
	case sinus_pressure
	case sinus_pain
	case sinus_coloredDischarge
	case sinus_toothPain
	case nose_stuffy
	case nose_itchy
	case nose_runny
	case nose_blood
	case throat_clearing
	case throat_sore
	case throat_hoarseVoice
	case throat_itchyScratchy
	case lungs_wheeze
	case lungs_cough
	case lungs_tightChest
	case lungs_shortBreath
	case skin_itch
	case skin_bumpsHives
	case skin_eczema
	case skin_swelling
	case meds_pill
	case meds_noseSpray
	case meds_inhaler
	case meds_topicalCream
	case wokeUp_groggyHead
	case wokeUp_stuffedUp
	case wokeUp_CrustyEyes
	case wokeUp_dryLips
	case nightTime_stuffy
	case nightTime_cough
	case nightTime_throatDrainage
	case nightTime_wheezeChest
	case pet_dog
	case pet_cat
	case pet_rodent
	case pet_horse
	case mold_home
	case mold_work
	case mold_school
	case mold_other
	case dust_home
	case dust_work
	case dust_school
	case dust_other
	case outdoors_playingSports
	case outdoors_airTravel
	case outdoors_someoneSick
	case outdoors_airPollution
	case energyLevel_great
	case energyLevel_medium
	case energyLevel_low
	case energyLevel_sick
	case headache_forehead
	case headache_sides
	case headache_back
	case headache_behindEyes
}


enum eyes_allergies:String{ case itchy, red, watery, bags }
enum sinus_allergies:String { case pressure, pain, colored_discharge, tooth_pain }
enum nose_allergies:String { case stuffy, itchy, runny, blood }
enum throat_allergies:String { case clearing, sore, hoarse_voice, itchy_scratchy }
enum lungs_allergies:String { case wheeze, cough, tight_chest, short_breath }
enum skin_allergies:String { case itch, bumps_hives, eczema, swelling }
enum meds_allergies:String { case pill, nose_spray, inhaler, topical_cream }
enum wokeUp_allergies:String { case groggy_head, stuffed_up, crusty_eyes, dry_lips }
enum nightTime_allergies:String { case stuffy, cough, throat_drainage, wheeze_chest }
enum pet_allergies:String { case dog, cat, rodent, horse }
enum mold_allergies:String { case home, work, school, other }
enum dust_allergies:String { case home, work, school, other }
enum outdoors_allergies:String { case playing_sports, air_travel, someone_sick, air_pollution }
enum energyLevel_allergies:String { case great, medium, low, sick }
enum headache_allergies:String { case forehead, sides, back, behind_eyes }

struct Allergies{
	var eyes:[eyes_allergies]?
	var sinus:[sinus_allergies]?
	var nose:[nose_allergies]?
	var throat:[throat_allergies]?
	var lungs:[lungs_allergies]?
	var skin:[skin_allergies]?
	var meds:[meds_allergies]?
	var wokeUp:[wokeUp_allergies]?
	var nightTime:[nightTime_allergies]?
	var pet:[pet_allergies]?
	var mold:[mold_allergies]?
	var dust:[dust_allergies]?
	var outdoors:[outdoors_allergies]?
	var energyLevel:[energyLevel_allergies]?
	var headache:[headache_allergies]?
}

func allAllergyConditions() -> [AllergyConditions]{
	return AllergyConditionsKeys.map({ AllergyConditions(rawValue: $0)! })
	//	var results:[AllergyConditions] = []
	//	var i = 0
	//	while let allergy = AllergyConditions(rawValue: i) {
	//		results.append(allergy)
	//		i += 1
	//	}
	//	return results
}

class AllergyEntry: NSObject {

	var date:Date
	var allergies:Allergies?
	
	func dictionary() -> [String:[String]]{
		var d:[String:[String]] = [:]
		if let a = allergies{
			if let y = a.eyes{ d["eyes"]=[String](); for z in y{d["eyes"]!.append(z.rawValue)} }
			if let y = a.sinus{ d["sinus"]=[String](); for z in y{d["sinus"]!.append(z.rawValue)} }
			if let y = a.nose{ d["nose"]=[String](); for z in y{d["nose"]!.append(z.rawValue)} }
			if let y = a.throat{ d["throat"]=[String](); for z in y{d["throat"]!.append(z.rawValue)} }
			if let y = a.lungs{ d["lungs"]=[String](); for z in y{d["lungs"]!.append(z.rawValue)} }
			if let y = a.skin{ d["skin"]=[String](); for z in y{d["skin"]!.append(z.rawValue)} }
			if let y = a.meds{ d["meds"]=[String](); for z in y{d["meds"]!.append(z.rawValue)} }
			if let y = a.wokeUp{ d["wokeUp"]=[String](); for z in y{d["wokeUp"]!.append(z.rawValue)} }
			if let y = a.nightTime{ d["nightTime"]=[String](); for z in y{d["nightTime"]!.append(z.rawValue)} }
			if let y = a.pet{ d["pet"]=[String](); for z in y{d["pet"]!.append(z.rawValue)} }
			if let y = a.mold{ d["mold"]=[String](); for z in y{d["mold"]!.append(z.rawValue)} }
			if let y = a.dust{ d["dust"]=[String](); for z in y{d["dust"]!.append(z.rawValue)} }
			if let y = a.outdoors{ d["outdoors"]=[String](); for z in y{d["outdoors"]!.append(z.rawValue)} }
			if let y = a.energyLevel{ d["energyLevel"]=[String](); for z in y{d["energyLevel"]!.append(z.rawValue)} }
			if let y = a.headache{ d["headache"]=[String](); for z in y{d["headache"]!.append(z.rawValue)} }
		}
		return d
	}
	
	func setFromDictionary( d:[String:[String]] ) {
		var a = Allergies()
		for (key,value) in d{
			switch key{
			case "eyes": a.eyes=[]; for v in value{if let e=eyes_allergies.init(rawValue:v){a.eyes!.append(e)} }
			case "sinus": a.sinus=[]; for v in value{if let e=sinus_allergies.init(rawValue:v){a.sinus!.append(e)} }
			case "nose": a.nose=[]; for v in value{if let e=nose_allergies.init(rawValue:v){a.nose!.append(e)} }
			case "throat": a.throat=[]; for v in value{if let e=throat_allergies.init(rawValue:v){a.throat!.append(e)} }
			case "lungs": a.lungs=[]; for v in value{if let e=lungs_allergies.init(rawValue:v){a.lungs!.append(e)} }
			case "skin": a.skin=[]; for v in value{if let e=skin_allergies.init(rawValue:v){a.skin!.append(e)} }
			case "meds": a.meds=[]; for v in value{if let e=meds_allergies.init(rawValue:v){a.meds!.append(e)} }
			case "wokeUp": a.wokeUp=[]; for v in value{if let e=wokeUp_allergies.init(rawValue:v){a.wokeUp!.append(e)} }
			case "nightTime": a.nightTime=[]; for v in value{if let e=nightTime_allergies.init(rawValue:v){a.nightTime!.append(e)} }
			case "pet": a.pet=[]; for v in value{if let e=pet_allergies.init(rawValue:v){a.pet!.append(e)} }
			case "mold": a.mold=[]; for v in value{if let e=mold_allergies.init(rawValue:v){a.mold!.append(e)} }
			case "dust": a.dust=[]; for v in value{if let e=dust_allergies.init(rawValue:v){a.dust!.append(e)} }
			case "outdoors": a.outdoors=[]; for v in value{if let e=outdoors_allergies.init(rawValue:v){a.outdoors!.append(e)} }
			case "energyLevel": a.energyLevel=[]; for v in value{if let e=energyLevel_allergies.init(rawValue:v){a.energyLevel!.append(e)} }
			case "headache": a.headache=[]; for v in value{if let e=headache_allergies.init(rawValue:v){a.headache!.append(e)} }
			default: break
			}
		}
	}

	func getDateString() -> String{
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: self.date)
	}

	override init() {
		// dates are initialized to NOW time, in user's time zone
		self.date = Date()
		super.init()
	}


	func log(){
//		print(self.values)
	}

}

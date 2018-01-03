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


enum eyes_allergies{ case itchy, red, watery, bags }
enum sinus_allergies { case pressure, pain, colored_discharge, tooth_pain }
enum nose_allergies { case stuffy, itchy, runny, blood }
enum throat_allergies { case clearing, sore, hoarse_voice, itchy_scratchy }
enum lungs_allergies { case wheeze, cough, tight_chest, short_breath }
enum skin_allergies { case itch, bumps_hives, eczema, swelling }
enum meds_allergies { case pill, nose_spray, inhaler, topical_cream }
enum wokeUp_allergies { case groggy_head, stuffed_up, crusty_eyes, dry_lips }
enum nightTime_allergies { case stuffy, cough, throat_drainage, wheeze_chest }
enum pet_allergies { case dog, cat, rodent, horse }
enum mold_allergies { case home, work, school, other }
enum dust_allergies { case home, work, school, other }
enum outdoors_allergies { case playing_sports, air_travel, someone_sick, air_pollution }
enum energyLevel_allergies { case great, medium, low, sick }
enum headache_allergies { case forehead, sides, back, behind_eyes }

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

func infrequentCharacterRemoval(_ paragraph:String) -> [Character]{
	let max = 50
	var dict:[Character:Int] = [:]
	let total = paragraph.count
	// count every character
	for letter in paragraph{
		if let entry = dict[letter]{
			dict[letter] = entry + 1
		} else{
			dict[letter] = 1
		}
	}
	
	let sortedKeys = Array(dict.keys).sorted { (a, b) -> Bool in
		return dict[a]! < dict[b]!
	}
	
	var cumulativeSum:Int = 0
	let cumulative = sortedKeys.map { (letter) -> Int in
		cumulativeSum += dict[letter] ?? 0
		return cumulativeSum
	}.map{
		total - $0
	}.filter{
		$0 > max
	}
	return Array(sortedKeys.prefix(cumulative.count))
}


class AllergyEntry: NSObject {

	var date:Date?
	var allergies:Allergies?
	
	func dictionary() -> [String:Any]{
		
		return []
	}

	func log(){
//		print(self.values)
	}

}

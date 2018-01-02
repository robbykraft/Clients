//
//  Allergy.swift
//  Allergy
//
//  Created by Robby on 11/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

/// ugh do better than this
let AllergyConditionsKeys = ["eyes_itchy", "eyes_red", "eyes_watery", "eyes_bags", "sinus_pressure", "sinus_pain", "sinus_coloredDischarge", "sinus_toothPain", "nose_stuffy", "nose_itchy", "nose_runny", "nose_blood", "throat_clearing", "throat_sore", "throat_hoarseVoice", "throat_itchyScratchy", "lungs_wheeze", "lungs_cough", "lungs_tightChest", "lungs_shortBreath", "skin_itch", "skin_bumpsHives", "skin_eczema", "skin_swelling", "meds_pill", "meds_noseSpray", "meds_inhaler", "meds_topicalCream", "wokeUp_groggyHead", "wokeUp_stuffedUp", "wokeUp_CrustyEyes", "wokeUp_dryLips", "nightTime_stuffy", "nightTime_cough", "nightTime_throatDrainage", "nightTime_wheezeChest", "pet_dog", "pet_cat", "pet_rodent", "pet_horse", "mold_home", "mold_work", "mold_school", "mold_other", "dust_home", "dust_work", "dust_school", "dust_other", "outdoors_playingSports", "outdoors_airTravel", "outdoors_someoneSick", "outdoors_airPollution", "energyLevel_great", "energyLevel_medium", "energyLevel_low", "energyLevel_sick", "headache_forehead", "headache_sides", "headache_back", "headache_behindEyes"]

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

class Allergy: NSObject {

	var date:Date?
	var values:[String:Int] = [:]

	func log(){
		print(self.values)
	}

}

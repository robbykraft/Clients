//
//  ClinicInfo.swift
//  ATXPollen
//
//  Created by Robby Kraft on 5/26/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation

struct ClinicHours{
	var days:String  // days is something like "M-F"
	var times:String  // times is something like "8am - 5pm"
	init(withDictionary dictionary:[String:AnyObject]){
		days = dictionary["days"] as? String ?? ""
		times = dictionary["times"] as? String ?? ""
	}
}

struct ClinicInfo{
	var address:String
	var phone:String
	var website:String
	var hours:[ClinicHours]
	init(withDictionary dictionary:[String:AnyObject]){
		address = dictionary["address"] as? String ?? ""
		phone = dictionary["phone"] as? String ?? ""
		website = dictionary["website"] as? String ?? ""
		hours = (dictionary["hours"] as? Array ?? []).map({ return ClinicHours(withDictionary: $0) })
	}
}

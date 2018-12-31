//
//  Room.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Room{
	var key:String = ""
	var name:String = "" // room name in database
	var customName:String? // rename a room
	var cost:Int? // force override dynamic calculation of room cost
	
	var furniture:[Furniture] = []
	
	init(name:String, key:String?){
		self.name = name
		if let k = key{
			self.key = k
		} else{
			self.key = Fire.shared.database.childByAutoId().key ?? ""
		}
	}
	
	func getCost() -> Int{
		if let custom = self.cost{
			return custom
		}
		var total:Float = 0.0
		for item in self.furniture{
			let thisCost = Voila.shared.priceForFurniture(name: item.name)
			let copies = item.copies
			total += thisCost * Float(copies)
		}		
		return Int(round(total/100)*100)
	}
	
	func databaseForm() -> [String:Any]{
		var dictionary:[String:Any] = [:]
		dictionary["name"] = name
		if let customName = self.customName{ dictionary["custom"] = customName }
		if let customCost = self.cost{ dictionary["cost"] = customCost }
		var furnitureDictionary:[String:Any] = [:]
		for furniture in self.furniture{
			furnitureDictionary[furniture.name] = furniture.copies
		}
		if furnitureDictionary.count > 0 {
			dictionary["furniture"] = furnitureDictionary
		}
		return dictionary
	}
	
}

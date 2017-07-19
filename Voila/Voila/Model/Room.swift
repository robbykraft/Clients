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
	
	var furniture:[Furniture] = []
	
	init(name:String, key:String?){
		self.name = name
		if let k = key{
			self.key = k
		} else{
			self.key = Fire.shared.database.childByAutoId().key
		}
	}
	
	func databaseForm() -> [String:Any]{
		var dictionary:[String:Any] = [:]
		dictionary["name"] = name
		if let custom = self.customName{ dictionary["custom"] = custom }
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

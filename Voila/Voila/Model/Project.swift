//
//  Project.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Project{
	var key:String = "" // the key in the database under "projects"

	var name:String = ""
	var active:Bool = true
	
	// contains furniture inside each room
	var rooms:[Room] = []
	
	func roomTypesAndCounts() -> [String:Int] {
		var dictionary:[String:Int] = [:]
		for i in 0..<self.rooms.count{
			let room = rooms[i].name
			if let roomExists = dictionary[room]{
				dictionary[room] = roomExists + 1
			} else{
				dictionary[room] = 1
			}
		}
		return dictionary
	}
	
	init(key:String, data:[String:Any]){
		self.key = key
		
		if let projectName = data["name"] as? String { self.name = projectName }
		if let active = data["active"] as? Bool { self.active = active }
		if let rooms = data["rooms"] as? [String:Any] {
			var roomArray:[Room] = []
			for (roomKey, object) in rooms{
				if let roomObject = object as? [String:Any]{
					if let roomName = roomObject["name"] as? String {
						let newRoom = Room(key: roomKey, name: roomName)
						if let customName = roomObject["customName"] as? String { newRoom.customName = customName }
						var furnitureArray:[Furniture] = []
						if let furnitureList = roomObject["furniture"] as? [String:Int]{
							for(furnitureName, count) in furnitureList{
								let newFurniture = Furniture(name: furnitureName, price: Voila.shared.priceForFurniture(name: furnitureName), room: newRoom)
								newFurniture.copies = count
								furnitureArray.append(newFurniture)
							}
						}
						newRoom.furniture = furnitureArray
						// finished building room
						roomArray.append(newRoom)
					}
				}
			}
			self.rooms = roomArray
		}
	}
	
	func update(completionHandler:@escaping() -> ()){
		
	}
	
}

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
	var archived:Bool = false
	
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
		if let archived = data["archived"] as? Bool { self.archived = archived }
		if let rooms = data["rooms"] as? [String:Any] {
			var roomArray:[Room] = []
			for (roomKey, object) in rooms{
				if let roomObject = object as? [String:Any]{
					if let roomName = roomObject["name"] as? String {
						let newRoom = Room(name: roomName, key: roomKey)
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
	
	func databaseForm() -> [String:Any]{
		var dictionary:[String:Any] = [:]
		dictionary["archived"] = self.archived
		dictionary["name"] = self.name
		var roomDictionary:[String:Any] = [:]
		for room in self.rooms{
			roomDictionary[room.key] = room.databaseForm()
		}
		dictionary["rooms"] = roomDictionary
		return dictionary
	}
	
//	func synchronize(target:[String:Int], completionHandler:(()->())?){
//		let current = self.roomTypesAndCounts()
//		for (roomKey,count) in target{
//			// iterate over all target ROOMS
//			if let currentCount = current[roomKey]{
//				// if room currently also exists, but number is different
//				if currentCount < count{
//					for _ in currentCount..<count{
//						Voila.shared.createRoom(roomType: roomKey, completionHandler: nil)
//					}
//				}
//				else if currentCount > count{
//					// remove room from everything really
//					
//				}
//			} else{
//				// ROOM does not currently exist
//				for i in 0..<count{
////					Voila.shared.addRoomToProject(roomKey)
//				}
//			}
//		}
//		// remove all ROOM in current if doesn't exist in target
//		for (key,_) in current{
//			if target[key] == nil{
//				self.rooms = self.rooms.filter({ $0.name != key })
//			}
//		}
//	}
	
	func synchronize(completionHandler:(() -> ())?){
		print("synchronizing")
		print(self.databaseForm())
		Fire.shared.setData(self.databaseForm(), at: "projects/" + self.key) { (success, ref) in
			if let completion = completionHandler{
				completion()
			}
		}
	}
	
}

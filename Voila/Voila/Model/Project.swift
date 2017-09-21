//
//  Project.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Project{
	
//	var clientName:String?
	
	var email:String?
	var lockbox:String?
	var clientName:String?
	var realtorName:String?
	var proposalSent:Int? // the unix timestamp of the date sent
	
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
	
	func furnitureCount() -> Int{
		var count = 0
		for room in rooms{
			for furniture in room.furniture{
				count += furniture.copies
			}
		}
		return count
	}
	
	init(key:String, data:[String:Any]){
		self.key = key
		
		// required meta
		if let projectName = data["name"] as? String { self.name = projectName }
		if let archived = data["archived"] as? Bool { self.archived = archived }
		// optional meta
		if let email = data["email"] as? String { self.email = email }
		if let lockbox = data["lockbox"] as? String { self.lockbox = lockbox }
		if let clientName = data["clientName"] as? String { self.clientName = clientName }
		if let realtorName = data["realtorName"] as? String { self.realtorName = realtorName }
		if let proposalSent = data["proposalSent"] as? Int { self.proposalSent = proposalSent }
		// room data
		if let rooms = data["rooms"] as? [String:Any] {
			var roomArray:[Room] = []
			for (roomKey, object) in rooms{
				if let roomObject = object as? [String:Any]{
					if let roomName = roomObject["name"] as? String {
						let newRoom = Room(name: roomName, key: roomKey)
						if let customName = roomObject["custom"] as? String { newRoom.customName = customName }
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
		// required meta
		dictionary["name"] = self.name
		dictionary["archived"] = self.archived
		// optional meta
		if let email = self.email{ dictionary["email"] = email }
		if let lockbox = self.lockbox{ dictionary["lockbox"] = lockbox }
		if let clientName = self.clientName{ dictionary["clientName"] = clientName }
		if let realtorName = self.realtorName{ dictionary["realtorName"] = realtorName }
		if let proposalSent = self.proposalSent{ dictionary["proposalSent"] = proposalSent }
		// rooms
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
//		print("synchronizing")
//		print(self.databaseForm())
		Fire.shared.setData(self.databaseForm(), at: "projects/" + self.key) { (success, ref) in
			if let completion = completionHandler{
				completion()
			}
		}
	}
	
	func setFromSmallTemplate(completionHandler:(() -> ())?){
		
		let bathroom = Room(name: "Bathroom", key: nil)
		bathroom.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: bathroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: bathroom),
			Furniture(name: "Bench", price: Voila.shared.priceForFurniture(name: "Bench"), room: bathroom),
			Furniture(name: "Console", price: Voila.shared.priceForFurniture(name: "Console"), room: bathroom),
			Furniture(name: "Laundry Basket", price: Voila.shared.priceForFurniture(name: "Laundry Basket"), room: bathroom),
			Furniture(name: "Poof", price: Voila.shared.priceForFurniture(name: "Poof"), room: bathroom),
			Furniture(name: "Rug", price: Voila.shared.priceForFurniture(name: "Rug"), room: bathroom),
			Furniture(name: "Towels", price: Voila.shared.priceForFurniture(name: "Towels"), room: bathroom)
		]
		let diningRoom = Room(name: "Dining Room", key: nil)
		let chairs = Furniture(name: "Dining Chairs", price: Voila.shared.priceForFurniture(name: "Dining Chairs"), room: diningRoom)
		chairs.copies = 4
		diningRoom.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: diningRoom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: diningRoom),
			chairs,
			Furniture(name: "Dining Table", price: Voila.shared.priceForFurniture(name: "Dining Table"), room: diningRoom)
		]
		let kitchen = Room(name: "Kitchen", key: nil)
		let stools = Furniture(name: "Counter Stools", price: Voila.shared.priceForFurniture(name: "Counter Stools"), room: kitchen)
		stools.copies = 2
		kitchen.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: kitchen),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: kitchen),
			stools
		]
		let livingRoom = Room(name: "Living Room", key: nil)
		livingRoom.furniture = [
			Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: livingRoom),
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: livingRoom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: livingRoom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: livingRoom),
			Furniture(name: "Coffee Table", price: Voila.shared.priceForFurniture(name: "Coffee Table"), room: livingRoom),
			Furniture(name: "Floor Lamp", price: Voila.shared.priceForFurniture(name: "Floor Lamp"), room: livingRoom),
			Furniture(name: "Side Table", price: Voila.shared.priceForFurniture(name: "Side Table"), room: livingRoom),
			Furniture(name: "Sofa", price: Voila.shared.priceForFurniture(name: "Sofa"), room: livingRoom)
		]
		let bedroom = Room(name: "Master Bedroom", key: nil)
		bedroom.furniture = [
			Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: bedroom),
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: bedroom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: bedroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: bedroom),
			Furniture(name: "Bed Frame", price: Voila.shared.priceForFurniture(name: "Bed Frame"), room: bedroom),
			Furniture(name: "Box Spring", price: Voila.shared.priceForFurniture(name: "Box Spring"), room: bedroom),
			Furniture(name: "Lamp", price: Voila.shared.priceForFurniture(name: "Lamp"), room: bedroom),
			Furniture(name: "Night Table", price: Voila.shared.priceForFurniture(name: "Night Table"), room: bedroom),
			Furniture(name: "Queen Bed", price: Voila.shared.priceForFurniture(name: "Queen Bed"), room: bedroom),
		]
		self.rooms = [bathroom, diningRoom, kitchen, livingRoom, bedroom];
		
		self.synchronize(completionHandler: {
			if let completion = completionHandler{
				completion()
			}
		})
	}
	
	
	
	func setFromLargeTemplate(completionHandler:(() -> ())?){
		
		let masterBathroom = Room(name: "Master Bathroom", key: nil)
		masterBathroom.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: masterBathroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: masterBathroom),
			Furniture(name: "Bench", price: Voila.shared.priceForFurniture(name: "Bench"), room: masterBathroom),
			Furniture(name: "Console", price: Voila.shared.priceForFurniture(name: "Console"), room: masterBathroom),
			Furniture(name: "Laundry Basket", price: Voila.shared.priceForFurniture(name: "Laundry Basket"), room: masterBathroom),
			Furniture(name: "Poof", price: Voila.shared.priceForFurniture(name: "Poof"), room: masterBathroom),
			Furniture(name: "Rug", price: Voila.shared.priceForFurniture(name: "Rug"), room: masterBathroom),
			Furniture(name: "Towels", price: Voila.shared.priceForFurniture(name: "Towels"), room: masterBathroom)
		]
		let bathroom = Room(name: "Bathroom", key: nil)
		bathroom.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: bathroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: bathroom),
			Furniture(name: "Bench", price: Voila.shared.priceForFurniture(name: "Bench"), room: bathroom),
			Furniture(name: "Console", price: Voila.shared.priceForFurniture(name: "Console"), room: bathroom),
			Furniture(name: "Laundry Basket", price: Voila.shared.priceForFurniture(name: "Laundry Basket"), room: bathroom),
			Furniture(name: "Poof", price: Voila.shared.priceForFurniture(name: "Poof"), room: bathroom),
			Furniture(name: "Rug", price: Voila.shared.priceForFurniture(name: "Rug"), room: bathroom),
			Furniture(name: "Towels", price: Voila.shared.priceForFurniture(name: "Towels"), room: bathroom)
		]
		let diningRoom = Room(name: "Dining Room", key: nil)
		let chairs = Furniture(name: "Dining Chairs", price: Voila.shared.priceForFurniture(name: "Dining Chairs"), room: diningRoom)
		chairs.copies = 4
		diningRoom.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: diningRoom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: diningRoom),
			chairs,
			Furniture(name: "Dining Table", price: Voila.shared.priceForFurniture(name: "Dining Table"), room: diningRoom)
		]
		let kitchen = Room(name: "Kitchen", key: nil)
		let stools = Furniture(name: "Counter Stools", price: Voila.shared.priceForFurniture(name: "Counter Stools"), room: kitchen)
		stools.copies = 3
		kitchen.furniture = [
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: kitchen),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: kitchen),
			stools
		]
		let familyRoom = Room(name: "Family Room", key: nil)
		let familyAccentChair = Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: familyRoom)
		let familyLamp = Furniture(name: "Floor Lamp", price: Voila.shared.priceForFurniture(name: "Floor Lamp"), room: familyRoom)
		let familySideTable = Furniture(name: "Side Table", price: Voila.shared.priceForFurniture(name: "Side Table"), room: familyRoom)
		familyAccentChair.copies = 2
		familyLamp.copies = 2
		familySideTable.copies = 2
		familyRoom.furniture = [
			familyAccentChair,
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: familyRoom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: familyRoom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: familyRoom),
			Furniture(name: "Coffee Table", price: Voila.shared.priceForFurniture(name: "Coffee Table"), room: familyRoom),
			Furniture(name: "Sectional", price: Voila.shared.priceForFurniture(name: "Sectional"), room: familyRoom),
			familyLamp,
			familySideTable
		]
		let livingRoom = Room(name: "Living Room", key: nil)
		let livingAccentChair = Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: livingRoom)
		let livingLamp = Furniture(name: "Floor Lamp", price: Voila.shared.priceForFurniture(name: "Floor Lamp"), room: livingRoom)
		let livingSideTable = Furniture(name: "Side Table", price: Voila.shared.priceForFurniture(name: "Side Table"), room: livingRoom)
		let livingSofa = Furniture(name: "Sofa", price: Voila.shared.priceForFurniture(name: "Sofa"), room: livingRoom)
		livingAccentChair.copies = 2
		livingLamp.copies = 2
		livingSideTable.copies = 2
		livingSofa.copies = 2
		livingRoom.furniture = [
			livingAccentChair,
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: livingRoom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: livingRoom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: livingRoom),
			Furniture(name: "Coffee Table", price: Voila.shared.priceForFurniture(name: "Coffee Table"), room: livingRoom),
			livingLamp,
			livingSideTable,
			livingSofa
		]
		let masterBedroom = Room(name: "Master Bedroom", key: nil)
		let masterLamp = Furniture(name: "Lamp", price: Voila.shared.priceForFurniture(name: "Lamp"), room: masterBedroom)
		let masterNightTable = Furniture(name: "Night Table", price: Voila.shared.priceForFurniture(name: "Night Table"), room: masterBedroom)
		masterLamp.copies = 2
		masterNightTable.copies = 2
		masterBedroom.furniture = [
			Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: masterBedroom),
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: masterBedroom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: masterBedroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: masterBedroom),
			Furniture(name: "Large Console", price: Voila.shared.priceForFurniture(name: "Large Console"), room: masterBedroom),
			Furniture(name: "Bed Frame", price: Voila.shared.priceForFurniture(name: "Bed Frame"), room: masterBedroom),
			Furniture(name: "Box Spring", price: Voila.shared.priceForFurniture(name: "Box Spring"), room: masterBedroom),
			masterLamp,
			masterNightTable,
			Furniture(name: "King Bed", price: Voila.shared.priceForFurniture(name: "King Bed"), room: masterBedroom),
		]
		let bedroom = Room(name: "Bedroom", key: nil)
		bedroom.furniture = [
			Furniture(name: "Accent Chair", price: Voila.shared.priceForFurniture(name: "Accent Chair"), room: bedroom),
			Furniture(name: "Accessories", price: Voila.shared.priceForFurniture(name: "Accessories"), room: bedroom),
			Furniture(name: "Area Rug", price: Voila.shared.priceForFurniture(name: "Area Rug"), room: bedroom),
			Furniture(name: "Art", price: Voila.shared.priceForFurniture(name: "Art"), room: bedroom),
			Furniture(name: "Bed Frame", price: Voila.shared.priceForFurniture(name: "Bed Frame"), room: bedroom),
			Furniture(name: "Box Spring", price: Voila.shared.priceForFurniture(name: "Box Spring"), room: bedroom),
			Furniture(name: "Lamp", price: Voila.shared.priceForFurniture(name: "Lamp"), room: bedroom),
			Furniture(name: "Night Table", price: Voila.shared.priceForFurniture(name: "Night Table"), room: bedroom),
			Furniture(name: "Queen Bed", price: Voila.shared.priceForFurniture(name: "Queen Bed"), room: bedroom),
		]
		self.rooms = [masterBathroom, bathroom, diningRoom, kitchen, livingRoom, familyRoom, masterBedroom, bedroom];
		
		self.synchronize(completionHandler: {
			if let completion = completionHandler{
				completion()
			}
		})
	}
}

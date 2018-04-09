//
//  Project.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Project{
	
	// the key in the database under "projects"
	var key:String = ""

	// required meta
	var name:String = ""
	var archived:Bool = false

	// optional meta
	var email:String?
	var lockbox:String?
	var clientName:String?
	var realtorName:String?
	var proposalSent:Int? // the unix timestamp of the date sent
	
	// stuff that gets filled when filling the proposal
	var discountTotal:Int?
	var discountPct:Int?
	var discountText:String?
	var taxPct:Float?
	var taxTotal:Int?
	var renewalsTotal:Int?
	var renewalsPct:Int?

	// contains furniture inside each room
	var rooms:[Room] = []
	
	// total cost. sum of the cost of all furniture in all rooms
	func cost() -> Int{
		return rooms.map({ return $0.getCost() }).reduce(0,+)
	}
	
	// returns all rooms in this project (keys) and quantity of each one (value)
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
	
	// an integer count of all furniture in all rooms
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
		if let proposalSent = data["date"] as? Int { self.proposalSent = proposalSent }
		// proposal
		if let discountTotal = data["discountTotal"] as? Int? { self.discountTotal = discountTotal }
		if let discountPct = data["discountPct"] as? Int? { self.discountPct = discountPct }
		if let discountText = data["discountText"] as? String? { self.discountText = discountText }
		if let taxPct = data["taxPct"] as? Float? { self.taxPct = taxPct }
		if let taxTotal = data["taxTotal"] as? Int? { self.taxTotal = taxTotal }
		if let renewalsTotal = data["renewalsTotal"] as? Int? { self.renewalsTotal = renewalsTotal }
		if let renewalsPct = data["renewalsPct"] as? Int? { self.renewalsPct = renewalsPct }
		// room data
		if let rooms = data["rooms"] as? [String:Any] {
			var roomArray:[Room] = []
			for (roomKey, object) in rooms{
				if let roomObject = object as? [String:Any]{
					if let roomName = roomObject["name"] as? String {
						let newRoom = Room(name: roomName, key: roomKey)
						if let customName = roomObject["custom"] as? String { newRoom.customName = customName }
						if let customCost = roomObject["cost"] as? Int { newRoom.cost = customCost }
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
			roomArray.sort(by: { (a, b) -> Bool in
				var aRank:Int = 0
				var bRank:Int = 0
				if let aR = Voila.shared.roomSort[a.name]{
					aRank = aR
				}
				if let bR = Voila.shared.roomSort[b.name]{
					bRank = bR
				}
				return aRank < bRank
			})
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
		if let proposalSent = self.proposalSent{ dictionary["date"] = proposalSent }
		// proposal
		if let discountTotal = self.discountTotal{ dictionary["discountTotal"] = discountTotal}
		if let discountPct = self.discountPct{ dictionary["discountPct"] = discountPct}
		if let discountText = self.discountText{ dictionary["discountText"] = discountText}
		if let taxPct = self.taxPct{ dictionary["taxPct"] = taxPct}
		if let taxTotal = self.taxTotal{ dictionary["taxTotal"] = taxTotal}
		if let renewalsTotal = self.renewalsTotal{ dictionary["renewalsTotal"] = renewalsTotal}
		if let renewalsPct = self.renewalsPct{ dictionary["renewalsPct"] = renewalsPct}

		// rooms
		var roomDictionary:[String:Any] = [:]
		for room in self.rooms{
			roomDictionary[room.key] = room.databaseForm()
		}
		dictionary["rooms"] = roomDictionary
		return dictionary
	}
	
	func synchronize(completionHandler:(() -> ())?){
		Fire.shared.setData(self.databaseForm(), at: "projects/" + self.key) { (success, ref) in
			if let completion = completionHandler{
				completion()
			}
		}
	}
	
	func setFromTemplate(type:TemplateTypes, completionHandler:(() -> ())?){
		
		if let selectedTemplate = Voila.shared.templates[type.rawValue]{
			var roomArray:[Room] = []
			for (roomName, furnitureList) in selectedTemplate{
				let thisRoom = Room(name: roomName, key: nil)
				var furnitureArray:[Furniture] = []
				for (furnitureName, furnitureCount) in furnitureList{
					let thisFurniture = Furniture(name: furnitureName, price: Voila.shared.priceForFurniture(name:furnitureName), room: thisRoom)
					thisFurniture.copies = furnitureCount
					furnitureArray.append(thisFurniture)
				}
				thisRoom.furniture = furnitureArray
				roomArray.append(thisRoom)
			}
			self.rooms = roomArray.sorted{ (a, b) -> Bool in
				var aRank:Int = 0
				var bRank:Int = 0
				if let aR = Voila.shared.roomSort[a.name]{
					aRank = aR
				}
				if let bR = Voila.shared.roomSort[b.name]{
					bRank = bR
				}
				return aRank < bRank
			}
			self.synchronize(completionHandler: {
				if let completion = completionHandler{
					completion()
				}
			})
		}
	}

}

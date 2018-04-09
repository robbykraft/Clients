

// these should match the keys in database at /data/templates/
enum TemplateTypes : String{
	case large
	case small
}


class Voila{
	static let shared = Voila()
	fileprivate init(){ }

	// master database of rooms (keys) and their furniture
	var furniture:[String:[Furniture]] = [:]
	var templates:[String:[String:[String:Int]]] = [:]
	var roomNames:[String] = []  // array of keys of above database
	var furnitureCost:[String:Float] = [:]

	let roomSort:[String:Int] = [
		"Foyer" : 2,
		"Living Room" : 3,
		"Kitchen" : 4,
		"Dining Room" : 5,
		"Family Room" : 6,
		"Master Bathroom" : 7,
		"Master Bedroom" : 8,
		"Bathrooms" : 9,
		"Bedroom" : 10,
		"Front Patio" : 11,
		"Deck,Patio" : 12,
		"Den" : 13,
		"Office" : 14,
		"Flex Space" : 15,
		"Game Room" : 16,
		"Hallways" : 17,
		"Basement" : 18,
		"Laundry Room" : 19,
		"Library" : 20,
		"Media Room" : 21,
		"Yard" : 22
	]

	var project:Project?{    // currently editing
		didSet{
			
		}
	}
	
	var roomKey:String?{ // currently editing room, the key of the room in the [Room] array in self.project
		// NO////the index of [Room] array in self.project
		didSet{
			
		}
	}
	
	// make sure to reload app data after deleting!
	func deleteProject(project:Project, completionHandler:(()->())?){
		Fire.shared.database.child("projects").child(project.key).removeValue { error in
			if let completion = completionHandler{
				completion()
			}
		}
	}

	func setCustomRoomName(customName:String, completionHandler:(()->())?){
		if let p = self.project{
			if let key = self.roomKey{
				for room in p.rooms{
					if room.key == key{
						room.customName = customName
						p.synchronize(completionHandler: { 
							if let completion = completionHandler{
								completion()
							}
						})
					}
				}
			}
		}
	}
	
	func currentRoom() -> Room?{
		if let p = self.project{
			if let index = self.currentRoomIndex(){
				if index < p.rooms.count{
					return p.rooms[index]
				}
			}
		}
		return nil
	}
	
	func currentRoomCustomFurniture() -> [Furniture]{
		let allFurnitureNames = Array(self.furnitureCost.keys)
		if let p = self.project{
			if let index = self.currentRoomIndex(){
				let room = p.rooms[index]
				return room.furniture.filter({ (furniture) -> Bool in
					return !allFurnitureNames.contains(furniture.name)
				})
			}
		}
		return []
	}
	
	func currentRoomAllFurniture()->[Furniture]{
		if let p = self.project{
			if let key = self.roomKey{
				for room in p.rooms{
					if room.key == key{
						if let furnitureArray = self.furniture[room.name]{
							return furnitureArray
						}
					}
				}
			}
		}
		return []
	}
	func currentRoomXORAllFurniture() -> [Furniture]{
		let currentRoomAllFurnitureNames = currentRoomAllFurniture().map { (f) -> String in
			return f.name
		}
		let allFurniture = Array(self.furnitureCost.keys).filter { (name) -> Bool in
			return !currentRoomAllFurnitureNames.contains(name)
		}
		return allFurniture.map({ (name) -> Furniture in
			return Furniture(name: name, price: self.priceForFurniture(name: name), room: nil)
		})
	}
	
	func currentRoomCurrentFurniture()->[Furniture]{
		if let p = self.project{
			if let key = self.roomKey{
				for room in p.rooms{
					if room.key == key{
						return room.furniture
					}
				}
			}
		}
		return []
	}
	
	func currentRoomName()->String?{
		if let p = self.project{
			if let key = self.roomKey{
				for room in p.rooms{
					if room.key == key{
						if let custom = room.customName{
							return custom
						}
						return room.name
					}
				}
			}
		}
		return nil
	}
	
	func currentRoomIndex()->Int?{
		if let key = self.roomKey{
			if let p = self.project{
				for i in 0 ..< p.rooms.count{
					if p.rooms[i].key == key{
						return i
					}
				}
			}
		}
		return nil
	}
	
	func setFurnitureCopies(furnitureName:String, copies:Int, completionHandler:(()->())?){
		if let project = self.project{
			if let key = self.roomKey{
				for i in 0 ..< project.rooms.count{
					if project.rooms[i].key == key{
						for j in 0 ..< project.rooms[i].furniture.count{
							if project.rooms[i].furniture[j].name == furnitureName{
								project.rooms[i].furniture[j].copies = copies
								// if copies is 0, remove item entirely
								if copies <= 0{ project.rooms[i].furniture.remove(at: j) }
								if let completion = completionHandler{
									completion()
								}
								return
							}
						}
						// furniture doesn't yet exist in room on project
						// TODO: price needs to be not 0
						let newFurniture = Furniture(name: furnitureName, price: 0, room: project.rooms[i])
						newFurniture.copies = copies
						project.rooms[i].furniture.append(newFurniture)
						if let completion = completionHandler{
							completion()
						}
						return
					}
				}
			}
		}
	}
	
	func priceForFurniture(name:String) -> Float{
		if let cost = self.furnitureCost[name]{
			return cost
		}
		return 0.0
	}
	
	func removeRoomFromProject(roomName:String) -> Bool{
		if let project = self.project{
			for i in (0..<project.rooms.count).reversed(){
				if project.rooms[i].name == roomName{
					project.rooms.remove(at: i)
					return true
				}
			}
		}
		return false
	}
	
	func boot(completionHandler:@escaping() -> ()){
		// step 1: get all furniture data
		Fire.shared.getData("data") { (data) in
			if let d = data as? [String:Any]{
				
				// get furniture:cost
				if let f = d["furniture"] as? [String:Float]{
					self.furnitureCost = f
				} else{
					// error, database has been corrupted at the "/data/furniture" level
					// see database backup files to reset the database to the correct state
				}
				
				// get rooms:furniture
				if let r = d["rooms"] as? [String:Any]{
					var furnitureDictionary:[String:[Furniture]] = [:]
					for (roomName, furnAr) in r{
						// iterate over room names
						var newRoomFurniture:[Furniture] = []
						// add all the furniture, cost, and other details
						if let furnitureArray = furnAr as? [String]{
							for furnitureString in furnitureArray{
								let cost:Float = self.furnitureCost[furnitureString] ?? 1
								let newFurniture = Furniture(name: furnitureString, price: cost, room: nil)
								newRoomFurniture.append(newFurniture)
							}
						}
						// all room furniture gathered
						furnitureDictionary[roomName] = newRoomFurniture.sorted(by: { (a, b) -> Bool in
							return a.name < b.name
						})
					}
					self.furniture = furnitureDictionary
					self.roomNames = Array(furnitureDictionary.keys).sorted()
				} else{
					// error, database has been corrupted at the "/data/rooms" level
					// see database backup files to reset the database to the correct state
				}
				
				// get room templates data
				if let templates = d["templates"] as? [String:[String:[String:Int]]]{
					self.templates = templates
				} else{
					// error, database has been corrupted at the "/data/templates" level
					// see database backup files to reset the database to the correct state
				}

			}
			
			completionHandler()
		}
	}

}

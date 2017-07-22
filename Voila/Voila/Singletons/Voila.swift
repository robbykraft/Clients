
class Voila{
	static let shared = Voila()
	fileprivate init(){ }

	// master database of rooms (keys) and their furniture
	var furniture:[String:[Furniture]] = [:]
	var roomNames:[String] = []  // array of keys of above database

	var project:Project?{    // currently editing
		didSet{
			
		}
	}
	
	var roomKey:String?{ // currently editing room, the key of the room in the [Room] arary in self.project
		// NO////the index of [Room] array in self.project
		didSet{
			
		}
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
		return 123.0
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
		Fire.shared.getData("data") { (data) in
			var furnitureDictionary:[String:[Furniture]] = [:]
			if let d = data as? [String:Any]{
				for (roomName, roomObject) in d{
					// iterate over room names
					var newRoomFurniture:[Furniture] = []
					// add all the furniture, cost, and other details
					if let furniture = roomObject as? [String:Any]{
						for (furnitureName, furnitureObject) in furniture{
							if let obj = furnitureObject as? [String:Any]{
								if let cost = obj["cost"] as? Float{
									let newFurniture = Furniture(name: furnitureName, price: cost, room: nil)
									newRoomFurniture.append(newFurniture)
								}
							}
						}
					}
					// all room furniture gathered
					furnitureDictionary[roomName] = newRoomFurniture
				}
			}
			self.furniture = furnitureDictionary
			self.roomNames = Array(furnitureDictionary.keys).sorted()
			completionHandler()
		}
	}
	
	func createRoom(roomType:String, completionHandler:(() -> ())?){
		
	}
	
	
}

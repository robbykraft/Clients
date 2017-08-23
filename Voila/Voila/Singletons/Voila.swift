
class Voila{
	static let shared = Voila()
	fileprivate init(){ }

	// master database of rooms (keys) and their furniture
	var furniture:[String:[Furniture]] = [:]
	var templates:[String:[Room]] = [:]
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
		// step 1: get all furniture data
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
			
			// step 2: get all templates
			Fire.shared.getData("templates") { (templates) in

				// in buildout, this will be replaced with a dynamic data pull from the database
				//  and results in the same objects being saved into self.templates
				self.makeTemplatesManually()
				
				completionHandler()
			}
		}
	}
	
	func makeTemplatesManually(){
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
		self.templates["small"] = [bathroom, diningRoom, kitchen, livingRoom, bedroom];
		
		// todo, needs actual large data
		self.templates["large"] = [bathroom, diningRoom, kitchen, livingRoom, bedroom];
	}
	
	
	func createRoom(roomType:String, completionHandler:(() -> ())?){
		
	}
}

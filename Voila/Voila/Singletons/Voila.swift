
class Voila{
	static let shared = Voila()
	fileprivate init(){ }

	// master database list of rooms and their furniture
	var rooms:[Room] = []
	var roomNames:[String] = []
//	var furniture:[String:[Furniture]] = [:]

	var project:Project?{    // currently editing
		didSet{
			
		}
	}
	
	func priceForFurniture(name:String) -> Float{
		return 123.0
	}
	
	func boot(completionHandler:@escaping() -> ()){
		Fire.shared.getData("data") { (data) in
			var roomArray:[Room] = []
			if let d = data as? [String:Any]{
				for (roomName, roomObject) in d{
					// iterate over room names
					let newRoom = Room(key: roomName, name: roomName)  // these are room templates they don't have keys
					var newRoomFurniture:[Furniture] = []
					// add all the furniture, cost, and other details
					if let furniture = roomObject as? [String:Any]{
						for (furnitureName, furnitureObject) in furniture{
							if let obj = furnitureObject as? [String:Any]{
								if let cost = obj["cost"] as? Float{
									let newFurniture = Furniture(name: furnitureName, price: cost, room: newRoom)
									newRoomFurniture.append(newFurniture)
								}
							}
						}
					}
					newRoom.furniture = newRoomFurniture
					// new room finished
					roomArray.append(newRoom)
				}
			}
			self.rooms = roomArray
			self.roomNames = self.rooms.map({ return $0.name }).sorted()
			completionHandler()
		}
	}
	

		
//	func boot(completionHandler:@escaping() -> ()){
//		Fire.shared.getData("data") { (data) in
//			if let d = data as? [String:Any]{
//				self.roomNames = Array(d.keys).sorted()
//				for room in self.roomNames{
//					// create a room object
//					self.furniture[room] = []
//					if let roomFurniture = d[room] as? [String:Any]{
//						let furnitureKeys = Array(roomFurniture.keys).sorted()
//						for key in furnitureKeys{
//							if let furnitureItem = roomFurniture[key] as? [String:Any]{
//								if let cost = furnitureItem["cost"] as? Int{
//									let furniture = Furniture(name: key, price: cost, room: room)
//									self.furniture[room]?.append(furniture)
//								}
//							}
//						}
//					}
//				}
//			}
//			completionHandler()
//		}
//	}
//	
}


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
	
	var room:Int?{ // currently editing room, the index of [Room] array in self.project
		didSet{
			
		}
	}
	
	func priceForFurniture(name:String) -> Float{
		return 123.0
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

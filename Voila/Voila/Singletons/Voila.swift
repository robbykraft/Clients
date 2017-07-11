
class Voila{
	static let shared = Voila()

	// both of these are arrays/dictionaries of room names
	var rooms:[String] = []
	// this one has furniture objects 
	var furniture:[String:[Furniture]] = [:]
	
	var projectKey:String?    // currently editing. the key to the proposal in the database
	var project:[String:Any]? // currently editing. the object of the proposal in the database
	
	fileprivate init(){ }
	
	func loadProject(key:String, object:[String:Any], completionHandler:@escaping() -> ()){
		self.projectKey = key
		self.project = object
		completionHandler()
	}
	
	func boot(completionHandler:@escaping() -> ()){
		Fire.shared.getData("data") { (data) in
			if let d = data as? [String:Any]{
				self.rooms = Array(d.keys).sorted()
				for room in self.rooms{
					self.furniture[room] = []
					if let roomFurniture = d[room] as? [String:Any]{
						let furnitureKeys = Array(roomFurniture.keys).sorted()
						for key in furnitureKeys{
							if let furnitureItem = roomFurniture[key] as? [String:Any]{
								if let cost = furnitureItem["cost"] as? Int{
									let furniture = Furniture(name: key, price: cost, room: room)
									self.furniture[room]?.append(furniture)
								}
							}
						}
					}
				}
			}
			completionHandler()
		}
	}
	
}


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
	
	
	//////////////////////////////////////////////////////////////////////////
	// PROPOSAL
	
	func htmlProposal()->String{
		return pageHeader + self.tableForProject() + termsAndConditionsText + pageFooter
	}
	
	func tableForProject()->String{
		var table = ""
		// header row
		table.append("<table><tr style=\"background-color:#555\"><td style=\"color:#FFF;\"><strong>Description</strong></td><td style=\"color:#FFF;\"><strong>Quantity</strong></td><td style=\"color:#FFF;\"><strong>Cost</strong></td></tr>")
		// for each room
		if let project = self.project{
			for room in project.rooms{
				var name = room.name
				if let custom = room.customName { name = custom }
				// first row, room name
				table.append("<tr style=\"background-color:#EEE\"><td><strong>" + name + "</strong></td><td></td><td></td></tr>")
				// rows of furniture items in the room
				for furniture in room.furniture{
					table.append("<tr><td>" + furniture.name + "</td><td>" + String(describing:furniture.copies) + "</td><td></td></tr>")
				}
				// last row, cost
				table.append("<tr><td></td><td></td><td><strong>$" + String(describing:room.getCost()) + "</strong></td></tr>")
			}
			table.append("<tr style=\"background-color:#555\"><td style=\"color:#FFF;\"><strong>Total</strong></td><td style=\"color:#FFF;\"></td><td style=\"color:#FFF;\"><strong>$2500</strong></td></tr>")
		}
		table.append("</table>")
		return table
	}
	
	
	var fakeTable = "<table><tr style=\"background-color:#555\"><td style=\"color:#FFF;\"><strong>Description</strong></td><td style=\"color:#FFF;\"><strong>Quantity</strong></td><td style=\"color:#FFF;\"><strong>Cost</strong></td></tr><tr style=\"background-color:#EEE\"><td><strong>Bathroom</strong></td><td></td><td></td></tr><tr><td>Accessories</td><td>1</td><td></td></tr><tr><td>Art</td><td>1</td><td></td></tr><tr><td>Bench</td><td>1</td><td></td></tr><tr><td>Console</td><td>1</td><td></td></tr><tr><td>Laundry Basket</td><td>1</td><td></td></tr><tr><td>Poof</td><td>1</td><td></td></tr><tr><td>Rug</td><td>1</td><td></td></tr><tr><td>Towels</td><td>1</td><td></td></tr><tr><td></td><td></td><td><strong>$500</strong></td></tr><tr style=\"background-color:#EEE\"><td><strong>Dining Room</strong></td><td></td><td></td></tr><tr><td>Accessories</td><td>1</td><td></td></tr><tr><td>Art</td><td>1</td><td></td></tr><tr><td>Dining Chairs</td><td>4</td><td></td></tr><tr><td>Dining Table</td><td>1</td><td></td></tr><tr><td></td><td></td><td><strong>$500</strong></td></tr><tr style=\"background-color:#EEE\"><td><strong>Kitchen</strong></td><td></td><td></td></tr><tr><td>Accessories</td><td>1</td><td></td></tr><tr><td>Art</td><td>1</td><td></td></tr><tr><td>Counter Stools</td><td>2</td><td></td></tr><tr><td></td><td></td><td><strong>$500</strong></td></tr><tr style=\"background-color:#EEE\"><td><strong>Living Room</strong></td><td></td><td></td></tr><tr><td>Accent Chair</td><td>1</td><td></td></tr><tr><td>Accessories</td><td>1</td><td></td></tr><tr><td>Area Rug</td><td>1</td><td></td></tr><tr><td>Art</td><td>1</td><td></td></tr><tr><td>Coffee Table</td><td>1</td><td></td></tr><tr><td>Floor Lamp</td><td>1</td><td></td></tr><tr><td>Side Table</td><td>1</td><td></td></tr><tr><td>Sofa</td><td>1</td><td></td></tr><tr><td></td><td></td><td><strong>$500</strong></td></tr><tr style=\"background-color:#EEE\"><td><strong>Master Bedroom</strong></td><td></td><td></td></tr><tr><td>Accent Chair</td><td>1</td><td></td></tr><tr><td>Accessories</td><td>1</td><td></td></tr><tr><td>Area Rug</td><td>1</td><td></td></tr><tr><td>Art</td><td>1</td><td></td></tr><tr><td>Bed Frame</td><td>1</td><td></td></tr><tr><td>Box Spring</td><td>1</td><td></td></tr><tr><td>Lamp</td><td>1</td><td></td></tr><tr><td>Night Table</td><td>1</td><td></td></tr><tr><td>Queen Bed</td><td>1</td><td></td></tr><tr><td></td><td></td><td><strong>$500</strong></td></tr><tr style=\"background-color:#555\"><td style=\"color:#FFF;\"><strong>Total</strong></td><td style=\"color:#FFF;\"></td><td style=\"color:#FFF;\"><strong>$2500</strong></td></tr></table>"
	
	var pageHeader = "<!DOCTYPE html><html><body style=\"background-color: #EEE; padding:2em; font-size:.4em;\"><div style=\"background-color: #FFF; padding:2em;\"><div style=\"text-align:center\"><img style=\"max-width:100%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-eda7d.appspot.com/o/logo.png?alt=media&token=9e4d2823-9d2e-4fd7-8240-d2f5c4ebb98d\"></div><div style=\"text-align:center\"><p style=\"color:#888;font-size: 1.3em;\">" +
		"Home Staging • Re-Styling • Interior Design • Developer Services • Painting" +
		"</p></div><p style=\"color:#888;font-style: italic;\">" +
		"Voila Design is Philadelphia’s award winning Home Staging and Interior Design firm. Awarded the \"Best of Philly\" accolade for Home Staging as well as a 26 episode Interior Design agreement with HGTV, the Voila Design team has proven themselves to be an industry leader in the Tri- State Area and beyond. The Voila Design team specializes in preparing properties to sell for the highest market value and in the shortest amount of time. Unlike the competition, Voila Design owns top of the line furnishings, accessories and artwork which allows every Home Staging project to be customized to suit each and every space. The award winning Voila Design team has the unique ability to turn a space from bland to grand in 24 hours or less!" +
	"</p><h2 style=\"text-align:center;\">Home Staging Proposal</h2><h2 style=\"text-align:center;\">1234 Park Pl. Springville</h2>"
	
	var pageFooter = "<hr><div style=\"text-align:center;\"><p><strong>Voila Design Home Services LLC</strong><br>267.688.2520<br><a href=\"mailto:tiffanyfasone@gmail.com\">tiffanyfasone@gmail.com</a><br><a href=\"http://voiladesignhome.com\">voiladesignhome.com</a><br><a href=\"https://www.google.com/maps/place/Voila+Design+Home/@39.9296906,-75.1710639,17z/\">1630 S Broad Street<br>Philadelphia, PA 19145</a></p></div></div></body></html>"
	
	var termsAndConditionsText = "<hr><h3 style=\"text-align:center;\">Home Staging Terms and Conditions</h3><div style=\"font-size: .8em;\"><h4>a) Definitions:</h4><p>Home Staging - Terms and Conditions<br>Base Contract: includes delivery of home staging services such as designer time, furniture moving in and out of property, transportation cost, rental of furniture and accessories for the preset period of time, typically three months. It is billed as one-time charge upon delivery.<br>Renewal Fee: includes rental of furniture and accessories for following periods upon Base Contract expiration. It is billed on a monthly base.</p><h4>b) Payment terms</h4><p>Upon accepting this proposal an advance payment of 50% of Base Contract price is due in order to secure a slot on our schedule. Balance payment is due 7 days before staging services are delivered and before any additional changes are made, if requested.<br>Base Contract fee shall not be prorated if the home sells prior to the end of the contract.</p><h4>c) Sales Tax</h4><p>Sales Tax is applied to home staging services.</p><h4>d) Payments methods</h4><p>Credit Cards and QuickBooks \"Pay Now\" feature: <strong>A processing fee of 2% of the transaction value is added to the total charge</strong>.<br>Checks: can be mailed to <strong>Voila Design Home Services LLC, 1630 S Broad St, Philadelphia PA 19145</strong></p><h4>e) When the property sells</h4><p>If the staged property goes under contract and passes most contingencies during the Base Contract time period, 7 days’ notice must be given in order to secure a pull date for removal of furniture out of the property. In case the removal’s request is received with less than 7 days’ notice a \"Rush Removal Fee\" of $250 will be automatically charged to Client.<br>If the property sells but Voila Design Home Services does not receive any notification or request for removal of furniture the Base Contract will continue and renewal fees will be eventually due.<br>If the staged property sells 48 hours before scheduled staging, Client may be charged 15% of staging costs for restocking.</p><h4>f) Renewals Terms</h4><p>When a Base Contract expires the Renewal Fee is due on monthly basis unless a request for furniture removal is sent to Voila Design Home Services within 7 days from Base Contract expiration date or any following renewal expiration date.<br>Unless other form of payment is provided, Renewal fees are automatically charged to Client’s credit card the first day of the renewal period.<br>Voila Design Home Services reserves the right to remove furniture from staged property in case of failure in monthly Renewal Fee payment.</p><h4>g) Disclaimer</h4><p>Client acknowledges that this staging contract is independent by any other real estate sales contract, agreement or arrangements between the Client and any other party such as, but not limited to: Buyer, Seller, developer, other contractors or real estate agencies involved in the listing, sale or purchase transactions.</p><h4>h) Client’s responsibilities</h4><p>Client agrees to allow access to the staged property to Voila Design Home Services employees during regular business hours (Monday to Friday 8.00am to 5.00 pm).<br>Client agrees to provide lock box and alarm codes for staged property as well as to keep keys in the lock box at all times during the length of this contract. Clients shall notify Voila Design Home Services when codes change.<br>Client is liable to take good care of the staged property, to maintain furniture in safe condition and to return all items to Voila Design Home Services in the condition received.<br>Client agrees to refund Voila Design Home Staging for any missing or damaged furniture item or accessories, including items missing or damaged as result of theft, vandalism, flood or fire at the property staged.<br>Client acknowledges that furnishings and accessories are owned by Voila Design Home Services and are intended for display purposes only. If there is evidence of habitation during the rental period, a cleaning/repair fee will be charged to client of at least $500.<br>Client acknowledges and agrees that all furnishings shall remain at the staged property during the entire term of this agreement and shall not be removed from the property, except by Voila Design Home Services’ staff.<br>Client is responsible to pay any third party fee such as move in/out fee, elevator fee, as required to deliver or remove the stage furniture.<br>All added personal items must be removed from the property prior to the final removal from the Voila Design Home Team. If personal items are added to the stage, Voila Design Home is not responsible if items are missing after the staging furniture and accessories are removed.<br>Client is responsible to ensure that the property is finished and ready for staging. This includes the interior unit, and corridors and stairwells leading to the unit, exterior of the building, outlining premises, and street to the building. If Voila Design Home Services’ team arrives to the property and is unable to deliver, client will be charged a $350 fee each time.<br>Voila Design Home Services is aware of the bedbug risks; we take extra measures to be pro-active in preventing an infestation. If an infestation should occur during the rental period, Voila Design Home Services will not be held liable for the damages. Furthermore, infestation will be considered a total loss and client is responsible for replacing the full value of the staging furniture.</p><h4>i) Our Commitment</h4><p>Voila Design Home Services’ team has the knowledge and proper experience to understand the aesthetics of any room. This is validated by the rate at which homes are sold as a result of Voila Design Home Services’estaging.<br>If Client is unhappy with the condition (damaged or dirty) pieces that are selected for the space, we will re-evaluate one time if necessary at no cost. A fee will apply for any additional re-evaluation.</p></div>"
	

}

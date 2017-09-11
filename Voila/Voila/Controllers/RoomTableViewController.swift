//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MessageUI

class RoomTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
	
//	var data:Room?{
//		didSet{
//			if let room = self.data{
//				self.title = room.name
//				if let customName = room.customName{
//					self.title = customName
//				}
//			}
//			self.tableView.reloadData()
//		}
//	}
	
	var data:[Furniture]?{
		didSet{
			
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.separatorStyle = .none

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "Proposal", style: .done, target: self, action: #selector(makeProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)
		
		self.title = Voila.shared.currentRoomName()

		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//	}
	
	func makeProposalHandler(){
		Voila.shared.sendProposal(self)
	}
	
	func addFurnitureHandler(){
		let nav = UINavigationController()
		nav.viewControllers = [AllRoomsTableViewController()]
		self.present(nav, animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Voila.shared.currentRoomAllFurniture().count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
		var count = 0
		for item in myFurnitureArray{
			count += item.copies
		}
		if count == 1 {return "\(count) Item"}
		return "\(count) Items"
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		// selection color
		let bgColorView = UIView()
		bgColorView.backgroundColor = Style.shared.cellSelectionColor
		cell.selectedBackgroundView = bgColorView

		let allFurnitureArray = Voila.shared.currentRoomAllFurniture()
		let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
		let furniture = allFurnitureArray[indexPath.row]
//		cell.textLabel?.text = furniture.name
//		
//		for myFurniture in furnitureArray{
//			if furniture.name == myFurniture.name{
//				cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
//				cell.textLabel?.textColor = Style.shared.blue
//				cell.detailTextLabel?.textColor = Style.shared.blue
//				cell.detailTextLabel?.text = "\(myFurniture.copies)"
//			}
//		}
//		if let myRoom = 

		cell.textLabel?.text = furniture.name
		
		for myFurniture in myFurnitureArray{
			if furniture.name == myFurniture.name{
				cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
				cell.textLabel?.textColor = Style.shared.blue
				cell.detailTextLabel?.textColor = Style.shared.blue
				cell.detailTextLabel?.text = "\(myFurniture.copies)"
			}
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let furnitureArray = Voila.shared.currentRoomAllFurniture()
		let furniture = furnitureArray[indexPath.row]
		
		let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
		for myFurniture in myFurnitureArray{
			print("built arrays")
			if furniture.name == myFurniture.name{
				print("found name match \(furniture.name)")
				let copies = myFurniture.copies
				print("currently \(copies) copies")
				Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: copies+1, completionHandler: {
					print("set furniture copies done")
					if let project = Voila.shared.project{
						project.synchronize(completionHandler: { 
							print("project synchronized")
							self.tableView.reloadData()
						})
					}
				})
				return
			}
		}
		// furniture doesn't exist yet
		Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 1, completionHandler: {
			print("set furniture copies done")
			if let project = Voila.shared.project{
				project.synchronize(completionHandler: {
					print("project synchronized")
					self.tableView.reloadData()
				})
			}
		})
		
	}

	
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Clear"
	}
	
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
			let furnitureArray = Voila.shared.currentRoomAllFurniture()
			let furniture = furnitureArray[indexPath.row]
			
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			for myFurniture in myFurnitureArray{
				print("built arrays")
				if furniture.name == myFurniture.name{
					print("found name match \(furniture.name)")
					let copies = myFurniture.copies
					print("currently \(copies) copies")
					Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 0, completionHandler: {
						print("set furniture copies done")
						if let project = Voila.shared.project{
							project.synchronize(completionHandler: {
								print("project synchronized")
								self.tableView.reloadData()
							})
						}
					})
					return
				}
			}
			
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
	
	
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		Voila.shared.mailDidFinish(result)
		self.dismiss(animated: true, completion: nil)
	}
	


}

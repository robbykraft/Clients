//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class RoomTableViewController: UITableViewController {
	
	var data:Room?{
		didSet{
			if let room = self.data{
				self.title = room.name
				if let customName = room.customName{
					self.title = customName
				}
			}
			self.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.separatorStyle = .none

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "Proposal", style: .done, target: self, action: #selector(makeProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
	func makeProposalHandler(){
		
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
		if let room = self.data{
			if let furnitureArray = Voila.shared.furniture[room.name]{
				return furnitureArray.count
			}
		}
		return 0
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		
		if let myRoom = self.data{
			if let furnitureArray = Voila.shared.furniture[myRoom.name]{

				let furniture = furnitureArray[indexPath.row]
				cell.textLabel?.text = furniture.name
				
				for myFurniture in myRoom.furniture{
					if furniture.name == myFurniture.name{
						cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
						cell.textLabel?.textColor = Style.shared.blue
						cell.detailTextLabel?.textColor = Style.shared.blue
						cell.detailTextLabel?.text = "\(myFurniture.copies)"
					}
				}
			}
		}
		
//		if let room = self.data{
//			let furniture = room.furniture[indexPath.row]
//			cell.textLabel?.text = furniture.name
//			cell.detailTextLabel?.text = "\(furniture.copies)"
//		}
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

}

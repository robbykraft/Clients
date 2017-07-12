//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
	
	var data:Project?{
		didSet{
			self.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.separatorStyle = .none

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "+", style: .done, target: self, action: #selector(addRoomHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black], for:.normal)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
	func addRoomHandler(){
		let nav = UINavigationController()
		nav.viewControllers = [AllRoomsTableViewController()]
		self.present(nav, animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let project = self.data{
			return project.name
		}
		return nil
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if let project = self.data{
			return project.rooms.count
		}
        return 0
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		if let project = self.data{
			let room = project.rooms[indexPath.row]
			cell.textLabel?.text = room.name
			if let customName = room.customName { cell.textLabel?.text = customName }
			cell.detailTextLabel?.text = "\(room.furniture.count)"
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let project = self.data{
			let room = project.rooms[indexPath.row]
			let vc = RoomTableViewController()
			vc.data = room
			self.navigationController?.pushViewController(vc, animated: true)
		}
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

//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if let project = Voila.shared.project{
			self.title = project.name
		}

		self.tableView.separatorStyle = .none

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "Proposal", style: .done, target: self, action: #selector(makeProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)
//		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black], for:.normal)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	func makeProposalHandler(){
		
	}
	
	func addRoomHandler(){
		let nav = UINavigationController()
		let vc = AllRoomsTableViewController()
		nav.viewControllers = [vc]
		self.present(nav, animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return nil
//			return "Project Settings"
		default:
			return "Rooms"
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section{
		case 0: return 1
		case 1:
			if let project = Voila.shared.project{
				return project.rooms.count + 1
			}
		default:
			return 0
		}
		return 0
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ProjectCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "Project Details"
			cell.textLabel?.textColor = Style.shared.gray
		default:
			if let project = Voila.shared.project{
				switch indexPath.row {
				case project.rooms.count:
					cell.textLabel?.text = "+/- Add / Remove Rooms"
					cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
					cell.textLabel?.textColor = Style.shared.blue
				default:
					let room = project.rooms[indexPath.row]
					cell.textLabel?.text = room.name
					if let customName = room.customName { cell.textLabel?.text = customName }
					if room.furniture.count <= 0 {
						cell.detailTextLabel?.text = "empty"
						cell.detailTextLabel?.textColor = Style.shared.blue
					}
				}
			}
		}
		return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section{
		case 0: break
		default:
			if let project = Voila.shared.project{
				switch indexPath.row{
				case project.rooms.count:
					self.addRoomHandler()
				default:
//					let room = project.rooms[indexPath.row]
//					Voila.shared.room = indexPath.row
					if let project = Voila.shared.project{
						Voila.shared.roomKey = project.rooms[indexPath.row].key
					}
					let vc = RoomTableViewController()
//					vc.data = room
					self.navigationController?.pushViewController(vc, animated: true)
				}
			}
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

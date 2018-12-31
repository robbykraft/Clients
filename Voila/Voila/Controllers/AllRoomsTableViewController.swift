//
//  AllRoomsTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class AllRoomsTableViewController: UITableViewController {
	
	var roomTypesAndCounts:[String:Int]?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Add/Remove Rooms"
		
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke

		if let project = Voila.shared.project{
			self.roomTypesAndCounts = project.roomTypesAndCounts()
			self.tableView.reloadData()
		}
		
		
		self.tableView.separatorStyle = .none
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneHandler))
		self.navigationItem.rightBarButtonItem = newBackButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSAttributedString.Key.foregroundColor: Style.shared.highlight], for:.normal)
}
	
	@objc func doneHandler(){
		// update
		
		self.dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Style.shared.P48
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Voila.shared.roomNames.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = TableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")

		let roomNameString = Voila.shared.roomNames[indexPath.row]
		cell.textLabel?.text = roomNameString
		
		if let types = self.roomTypesAndCounts{
			if let count = types[roomNameString]{
				cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: (cell.textLabel?.font.pointSize)!)
				cell.textLabel?.textColor = Style.shared.highlight
				cell.detailTextLabel?.textColor = Style.shared.highlight
				cell.detailTextLabel?.text = "\(count)"
			}
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let roomNameString = Voila.shared.roomNames[indexPath.row]
		if Voila.shared.project != nil {
			let newRoom = Room(name: roomNameString, key: nil)
			Voila.shared.project!.rooms.append(newRoom)
			Voila.shared.project!.synchronize(completionHandler: {
				self.roomTypesAndCounts = Voila.shared.project!.roomTypesAndCounts()
				self.tableView.reloadData()
			})
		}
		tableView.reloadData()
	}

	
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "- 1"
	}
	
    // Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			let roomNameString = Voila.shared.roomNames[indexPath.row]
			if Voila.shared.removeRoomFromProject(roomName: roomNameString) == true{
				Voila.shared.project!.synchronize(completionHandler: {
					self.roomTypesAndCounts = Voila.shared.project!.roomTypesAndCounts()
					self.tableView.reloadData()
				})
			}
        } else if editingStyle == .insert { }
    }

}

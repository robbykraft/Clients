//
//  AllFurnitureViewController.swift
//  Voila
//
//  Created by Robby on 1/29/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class AllFurnitureViewController: UITableViewController {
	
	let furnitureTypes:[String] = Array(Voila.shared.furnitureCost.keys).sorted()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Add Furniture Type"
		
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.tableView.separatorStyle = .none
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneHandler))
		self.navigationItem.rightBarButtonItem = newBackButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.highlight], for:.normal)
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}
	
	func doneHandler(){
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
		return furnitureTypes.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = TableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		
		let furnitureName = furnitureTypes[indexPath.row]
		cell.textLabel?.text = furnitureName
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let furnitureName = furnitureTypes[indexPath.row]
		if Voila.shared.project != nil {
			for r in 0..<Voila.shared.project!.rooms.count{
				if Voila.shared.project!.rooms[r].name == Voila.shared.currentRoomName(){
					if !Voila.shared.project!.rooms[r].furniture.contains(where: { (furniture) -> Bool in
						furniture.name == furnitureName
					}){
						let newFurniture = Furniture(name: furnitureName, price: 0, room: Voila.shared.project!.rooms[r])
						Voila.shared.project!.rooms[r].furniture.append(newFurniture)
					}
				}
			}
		}
		self.dismiss(animated: true, completion: nil)
	}
	
}



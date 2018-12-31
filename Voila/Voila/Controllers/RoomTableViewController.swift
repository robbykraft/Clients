//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
//import MessageUI

class RoomTableViewController: UITableViewController { //}, MFMailComposeViewControllerDelegate {
	
	var data:[Furniture]?{
		didSet{
			
		}
	}
	
	let titleButton = UIButton(type: .custom)
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.separatorStyle = .none

		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "Proposal", style: .done, target: self, action: #selector(makeProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSAttributedString.Key.foregroundColor: Style.shared.highlight], for:.normal)
		
		
		titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
		titleButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
		titleButton.setTitleColor(UIColor.black, for: .normal)
		if let thisRoomName = Voila.shared.currentRoomName(){
			titleButton.setTitle(thisRoomName, for: .normal)
		}
		titleButton.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
		self.navigationItem.titleView = titleButton
    }
	
	@objc func clickOnButton(button: UIButton) {
		let alertController = UIAlertController(title: "Custom Name", message: "Give this room a custom name?", preferredStyle: .alert)
		alertController.addTextField { (textField : UITextField) -> Void in
			textField.placeholder = "Room Name"
			textField.autocapitalizationType = .words
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
		}
		let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
			if let fields = alertController.textFields{
				if let text = fields.first!.text{
					Voila.shared.setCustomRoomName(customName: text, completionHandler: {
						self.titleButton.setTitle(Voila.shared.currentRoomName(), for: .normal)
						self.titleButton.sizeToFit()
					})
				}
			}
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	@objc func makeProposalHandler(){
		self.navigationController?.pushViewController(ProposalViewController(), animated: true)
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

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Style.shared.P48
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1 + Voila.shared.currentRoomCustomFurniture().count
		case 1: return Voila.shared.currentRoomAllFurniture().count
		case 2: return Voila.shared.currentRoomXORAllFurniture().count
		default: return 1
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Custom Furniture"
		case 1: return "Typical \(Voila.shared.currentRoomName() ?? "") Furniture"
		case 2: return "All Furniture"
		default:
			let roomName = Voila.shared.currentRoomName() ?? ""
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			var count = 0
			for item in myFurnitureArray{
				count += item.copies
			}
			if count == 1 {return roomName + ": \(count) Item"}
			return roomName + ": \(count) Items"

		}
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = TableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		
		switch indexPath.section {
		case 0:
			switch indexPath.row{
			case 0:
				cell.textLabel?.text = "Custom Furniture Item"
				cell.textLabel?.textColor = Style.shared.red
			default:
				let adjustedRow = indexPath.row - 1
				let customFurnitureArray = Voila.shared.currentRoomCustomFurniture()
				if adjustedRow < customFurnitureArray.count {
					cell.textLabel?.text = customFurnitureArray[adjustedRow].name
					cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: (cell.textLabel?.font.pointSize)!)
					cell.textLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.text = "\(customFurnitureArray[adjustedRow].copies)"
				}
			}
			return cell
		case 1:
			let allFurnitureArray = Voila.shared.currentRoomAllFurniture()
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			let furniture = allFurnitureArray[indexPath.row]
			cell.textLabel?.text = furniture.name
			for myFurniture in myFurnitureArray{
				if furniture.name == myFurniture.name{
					cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: (cell.textLabel?.font.pointSize)!)
					cell.textLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.text = "\(myFurniture.copies)"
				}
			}
		case 2:
			let allFurnitureArray = Voila.shared.currentRoomXORAllFurniture()
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			let furniture = allFurnitureArray[indexPath.row]
			cell.textLabel?.text = furniture.name
			for myFurniture in myFurnitureArray{
				if furniture.name == myFurniture.name{
					cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: (cell.textLabel?.font.pointSize)!)
					cell.textLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.textColor = Style.shared.highlight
					cell.detailTextLabel?.text = "\(myFurniture.copies)"
				}
			}
		default: break
		}
		return cell
    }
	
	func createNewFurniturePopover(){
		let alertController = UIAlertController(title: "Create New Furniture Item", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField : UITextField) -> Void in
			textField.placeholder = "Furniture Name"
			textField.autocapitalizationType = UITextAutocapitalizationType.words
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
		}
		let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
			if let fields = alertController.textFields{
				if let text = fields.first!.text{
					let newFurniture = Furniture(name: text, price: 0, room: Voila.shared.currentRoom())
					Voila.shared.setFurnitureCopies(furnitureName: newFurniture.name, copies: 1, completionHandler: {
						if let project = Voila.shared.project{
							project.synchronize(completionHandler: {
								self.tableView.reloadData()
							})
						}
					})
				}
			}
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)

	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row{
			case 0: self.createNewFurniturePopover()
			default:
				let adjustedRow = indexPath.row - 1
				let customFurnitureArray = Voila.shared.currentRoomCustomFurniture()
				let furniture = customFurnitureArray[adjustedRow]
				let copies = furniture.copies
				Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: copies+1, completionHandler: {
					if let project = Voila.shared.project{
						project.synchronize(completionHandler: {
							self.tableView.reloadData()
						})
					}
				})
				return

			}
			
			return
		case 1:
			let furnitureArray = Voila.shared.currentRoomAllFurniture()
			let furniture = furnitureArray[indexPath.row]
			
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			for myFurniture in myFurnitureArray{
				if furniture.name == myFurniture.name{
					let copies = myFurniture.copies
					Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: copies+1, completionHandler: {
						if let project = Voila.shared.project{
							project.synchronize(completionHandler: {
								self.tableView.reloadData()
							})
						}
					})
					return
				}
			}
			// furniture doesn't exist yet
			Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 1, completionHandler: {
				if let project = Voila.shared.project{
					project.synchronize(completionHandler: {
						self.tableView.reloadData()
					})
				}
			})
		case 2:
			let furnitureArray = Voila.shared.currentRoomXORAllFurniture()
			let furniture = furnitureArray[indexPath.row]
			let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
			for myFurniture in myFurnitureArray{
				if furniture.name == myFurniture.name{
					let copies = myFurniture.copies
					Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: copies+1, completionHandler: {
						if let project = Voila.shared.project{
							project.synchronize(completionHandler: {
								self.tableView.reloadData()
							})
						}
					})
					return
				}
			}
			// furniture doesn't exist yet
			Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 1, completionHandler: {
				if let project = Voila.shared.project{
					project.synchronize(completionHandler: {
						self.tableView.reloadData()
					})
				}
			})

		default: break
		}
		
		
	}

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0: return false
			default: return true
			}
		default: return true
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Clear"
	}
	
    // Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			switch indexPath.section{
			case 0:
				let adjustedRow = indexPath.row - 1
				let customFurnitureArray = Voila.shared.currentRoomCustomFurniture()
				let furniture = customFurnitureArray[adjustedRow]
				Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 0, completionHandler: {
					if let project = Voila.shared.project{
						project.synchronize(completionHandler: {
							self.tableView.reloadData()
						})
					}
				})
			case 1:
				let furnitureArray = Voila.shared.currentRoomAllFurniture()
				let furniture = furnitureArray[indexPath.row]
				let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
				for myFurniture in myFurnitureArray{
					if furniture.name == myFurniture.name{
						Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 0, completionHandler: {
							if let project = Voila.shared.project{
								project.synchronize(completionHandler: {
									self.tableView.reloadData()
								})
							}
						})
						return
					}
				}
			case 2:
				let allFurnitureArray = Voila.shared.currentRoomXORAllFurniture()
				let myFurnitureArray = Voila.shared.currentRoomCurrentFurniture()
				let furniture = allFurnitureArray[indexPath.row]
				for myFurniture in myFurnitureArray{
					if furniture.name == myFurniture.name{
						Voila.shared.setFurnitureCopies(furnitureName: furniture.name, copies: 0, completionHandler: {
							if let project = Voila.shared.project{
								project.synchronize(completionHandler: {
									self.tableView.reloadData()
								})
							}
						})
						return
					}
				}
			default: break
			}
			
        } else if editingStyle == .insert { }
    }

}

//
//  RoomTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
//import MessageUI

class ProjectTableViewController: UITableViewController {//}, MFMailComposeViewControllerDelegate {
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if let project = Voila.shared.project{
			self.title = project.name
		}
		
		self.tableView.separatorStyle = .none
		
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		let addButton = UIBarButtonItem.init(title: "Proposal", style: .done, target: self, action: #selector(makeProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.highlight], for:.normal)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		if let project = Voila.shared.project{
			self.title = project.name
		}
	}
	
	func makeProposalHandler(){
//		Voila.shared.sendProposal(self)
		self.navigationController?.pushViewController(ProposalViewController(), animated: true)
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
		default:
			return "Rooms"
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Style.shared.P48
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
		let cell = TableViewCell.init(style: .value1, reuseIdentifier: "ProjectCell")

		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "Project Details"
			cell.textLabel?.textColor = Style.shared.gray
			
			if let project = Voila.shared.project{
				if project.email != nil && project.email! != ""{
					cell.detailTextLabel?.text = ""
				} else{
					cell.detailTextLabel?.text = "email needed"
					cell.detailTextLabel?.textColor = Style.shared.red
				}
			}
		default:
			if let project = Voila.shared.project{
				switch indexPath.row {
				case project.rooms.count:
					cell.textLabel?.text = "+/- Add / Remove Rooms"
					cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
					cell.textLabel?.textColor = Style.shared.highlight
				default:
					let room = project.rooms[indexPath.row]
					cell.textLabel?.text = room.name
					if let customName = room.customName {
						cell.textLabel?.text = customName
					}
					if room.furniture.count <= 0 {
						cell.detailTextLabel?.text = "empty"
						cell.detailTextLabel?.textColor = Style.shared.highlight
					}
				}
			}
		}
		return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section{
		case 0:
			self.navigationController?.pushViewController(EditProjectViewController(), animated: true)
			break
		default:
			if let project = Voila.shared.project{
				switch indexPath.row{
				case project.rooms.count:
					self.addRoomHandler()
				default:
					if let project = Voila.shared.project{
						Voila.shared.roomKey = project.rooms[indexPath.row].key
					}
					let vc = RoomTableViewController()
					self.navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
	}

}

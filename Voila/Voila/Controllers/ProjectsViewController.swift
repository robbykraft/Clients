//
//  ProjectsViewController.swift
//  Voila
//
//  Created by Robby on 7/5/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProjectsViewController: UITableViewController {
	
	var projects:[Project] = []{
		didSet{
			self.tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Projects"

		self.tableView.separatorStyle = .none
		
//		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
		self.navigationItem.leftBarButtonItem = newBackButton
		self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.black], for:.normal)

		let addButton = UIBarButtonItem.init(title: "+", style: .done, target: self, action: #selector(addProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black], for:.normal)

		Fire.shared.getData("projects") { (data) in
			var projectArray:[Project] = []
			if let d = data as? [String:[String:Any]]{
				for (key, value) in d{
					projectArray.append(Project(key: key, data: value))
				}
			}
			self.projects = projectArray
		}
        // Do any additional setup after loading the view.
    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		default:
			return self.projects.count
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "New"
		default:
			return "Current"
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if(indexPath.section == 0){
			let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CreateProjectCell")
			cell.textLabel?.text = "Create Project"
			return cell
		}
		let project = self.projects[indexPath.row]
		
		let cell = UITableViewCell.init(style: .default, reuseIdentifier: "ProjectCell")
		cell.textLabel?.text = project.name
		cell.detailTextLabel?.text = "\(project.rooms.count) rooms"
		if(project.rooms.count == 1) { cell.detailTextLabel?.text = "\(project.rooms.count) room" }
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		Voila.shared.project = self.projects[indexPath.row]
		let vc = ProjectTableViewController()
		vc.data = self.projects[indexPath.row]
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func addProposalHandler(){
		self.dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

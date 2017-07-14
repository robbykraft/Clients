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
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
//		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
//		self.navigationItem.leftBarButtonItem = newBackButton
//		self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.black], for:.normal)

		let addButton = UIBarButtonItem.init(title: "Settings", style: .done, target: self, action: #selector(newProjectHandler))
		self.navigationItem.rightBarButtonItem = addButton
//		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black], for:.normal)

        // Do any additional setup after loading the view.
		self.reloadData(nil)
    }
	
	func reloadData(_ completionHandler:(() -> ())?){
		Fire.shared.getData("projects") { (data) in
			var projectArray:[Project] = []
			if let d = data as? [String:[String:Any]]{
				for (key, value) in d{
					projectArray.append(Project(key: key, data: value))
				}
			}
			self.projects = projectArray
			if let completion = completionHandler{
				completion()
			}
		}
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

		let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CreateProjectCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		switch indexPath.section{
		case 0:
			cell.textLabel?.text = "Create Project"
		default:
			let project = self.projects[indexPath.row]
			cell.textLabel?.text = project.name
			cell.detailTextLabel?.text = "\(project.rooms.count) rooms"
			if(project.rooms.count == 1) { cell.detailTextLabel?.text = "\(project.rooms.count) room" }
		}
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
	
	func newProjectHandler(){
		let alertController = UIAlertController(title: "New Project", message: nil, preferredStyle: UIAlertControllerStyle.alert)
		alertController.addTextField { (textField : UITextField) -> Void in
			textField.placeholder = "Project Name"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
		}
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
			if let fields = alertController.textFields{
				if let text = fields.first!.text{
					Fire.shared.addData(["name":text, "active":true], asChildAt: "projects", completionHandler: { (success, newKey, ref) in
						self.reloadData({
							if let key = newKey{
								for project in self.projects{
									if project.key == key{
										Voila.shared.project = project
										let vc = ProjectTableViewController()
										vc.data = Voila.shared.project
										self.navigationController?.pushViewController(vc, animated: true)
									}
								}
							}
						})
					})
				}
			}
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

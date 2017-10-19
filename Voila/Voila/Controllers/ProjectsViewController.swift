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
		self.title = "Voila"
		let titleImage = UIImageView(image: UIImage(named: "logo"))
		titleImage.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
		titleImage.contentMode = .scaleAspectFit
		titleImage.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
		self.navigationItem.titleView = titleImage

		

		self.tableView.separatorStyle = .none
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

//		let settingsButton = UIBarButtonItem.init(title: "Settings", style: .done, target: self, action: #selector(settingsHandler))
//		self.navigationItem.leftBarButtonItem = settingsButton
//		self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)
		
		let addButton = UIBarButtonItem.init(title: "+", style: .done, target: self, action: #selector(self.newProjectHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)

        // Do any additional setup after loading the view.
		self.reloadData(nil)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()
	}
	
	func reloadData(_ completionHandler:(() -> ())?){
		Fire.shared.getData("projects") { (data) in
			var projectArray:[Project] = []
			if let d = data as? [String:[String:Any]]{
				for (key, value) in d{
					projectArray.append(Project(key: key, data: value))
				}
			}
			projectArray.sort(by: { (a, b) -> Bool in
				return a.name < b.name
			})
			self.projects = projectArray
			if let completion = completionHandler{
				completion()
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		switch indexPath.section{
//		case 0: return 44
//		default: return 90
//		}
		return 90
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
//		return 2
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		switch section {
//		case 0:
//			return 1
//		default:
			return self.projects.count
//		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		switch section {
//		case 0:
//			return nil
//		default:
			return "Current"
//		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//		switch indexPath.section{
//		case 0:
//			let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CreateProjectCell")
//			cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
//			cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
//			cell.textLabel?.text = "Create Project"
//			// selection color
//			let bgColorView = UIView()
//			bgColorView.backgroundColor = Style.shared.cellSelectionColor
//			cell.selectedBackgroundView = bgColorView
//			return cell
//		default:
			let cell = ProjectTableViewCell()
			let project = self.projects[indexPath.row]
			cell.data = project;
			return cell
//		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		switch indexPath.section{
//		case 0:
//			self.newProjectHandler()
//			tableView.deselectRow(at: indexPath, animated: true)
//		default:
			Voila.shared.project = self.projects[indexPath.row]
			let vc = ProjectTableViewController()
			self.navigationController?.pushViewController(vc, animated: true)
//		}
	}
	
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Delete"
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
			let project = self.projects[indexPath.row]
			Voila.shared.deleteProject(project: project, completionHandler: {
				self.reloadData(nil)
			})
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	

	func settingsHandler(){
		
	}
	
	func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func fillTemplate(){
		let alertController = UIAlertController(title: "Begin from a template?", message: nil, preferredStyle: .alert)
		let template1Action = UIAlertAction(title: "Small 1 Bedroom", style: .default) { (result : UIAlertAction) -> Void in
			Voila.shared.project?.setFromSmallTemplate(completionHandler: {
				let vc = ProjectTableViewController()
				self.navigationController?.pushViewController(vc, animated: true)
			})
		}
		let template2Action = UIAlertAction(title: "Large 2 Bedroom", style: .default) { (result : UIAlertAction) -> Void in
			Voila.shared.project?.setFromLargeTemplate(completionHandler: {
				let vc = ProjectTableViewController()
				self.navigationController?.pushViewController(vc, animated: true)
			})
		}
		let skipAction = UIAlertAction(title: "Skip", style: .cancel) { (result : UIAlertAction) -> Void in
			let vc = ProjectTableViewController()
			self.navigationController?.pushViewController(vc, animated: true)

		}
		alertController.addAction(template1Action)
		alertController.addAction(template2Action)
		alertController.addAction(skipAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func newProjectHandler(){
		let alertController = UIAlertController(title: "New Project Name", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField : UITextField) -> Void in
			textField.placeholder = "Project Name"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
		}
		let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
			if let fields = alertController.textFields{
				if let text = fields.first!.text{
					Fire.shared.addData(["name":text, "archived":false], asChildAt: "projects", completionHandler: { (success, newKey, ref) in
						self.reloadData({
							if let key = newKey{
								for project in self.projects{
									if project.key == key{
										Voila.shared.project = project
										self.fillTemplate()
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

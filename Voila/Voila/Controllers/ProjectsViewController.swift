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

//		self.view.backgroundColor = .white
		self.view.backgroundColor = Style.shared.whiteSmoke

		self.tableView.separatorStyle = .none
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		
		let proposalsButton = UIBarButtonItem.init(title: "Proposals", style: .done, target: self, action: #selector(allProposalsHandler))
		self.navigationItem.leftBarButtonItem = proposalsButton
		self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.highlight], for:.normal)
		
		let addButton = UIBarButtonItem.init(title: "+", style: .done, target: self, action: #selector(self.newProjectHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)!, NSForegroundColorAttributeName: Style.shared.highlight], for:.normal)

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
//			projectArray.sort(by: { (a, b) -> Bool in
//				return a.name < b.name
//			})
			self.projects = projectArray.sorted{$0.name.localizedStandardCompare($1.name) == .orderedAscending}
			if let completion = completionHandler{
				completion()
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.projects.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Active Projects"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = ProjectTableViewCell()
		let project = self.projects[indexPath.row]
		cell.data = project;
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		Voila.shared.project = self.projects[indexPath.row]
		let vc = ProjectTableViewController()
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
		override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Delete"
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let project = self.projects[indexPath.row]
			Voila.shared.deleteProject(project: project, completionHandler: {
				self.reloadData(nil)
			})
		} else if editingStyle == .insert { }
	}
	
	

	func allProposalsHandler(){
		self.navigationController?.pushViewController(ProposalsTableViewController(), animated: true)
	}
	
	func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func fillTemplate(){
		let alertController = UIAlertController(title: "Begin from a template?", message: nil, preferredStyle: .alert)
		let template1Action = UIAlertAction(title: "Small 1 Bedroom", style: .default) { (result : UIAlertAction) -> Void in
			Voila.shared.project?.setFromTemplate(type: .small, completionHandler: {
				let vc = ProjectTableViewController()
				self.navigationController?.pushViewController(vc, animated: true)
			})
		}
		let template2Action = UIAlertAction(title: "Large 2 Bedroom", style: .default) { (result : UIAlertAction) -> Void in
			Voila.shared.project?.setFromTemplate(type: .large, completionHandler: {
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
			textField.autocapitalizationType = UITextAutocapitalizationType.words
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

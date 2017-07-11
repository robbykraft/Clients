//
//  ProjectsViewController.swift
//  Voila
//
//  Created by Robby on 7/5/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProjectsViewController: UITableViewController {
	
	var projects:[String:Any] = [:]{
		didSet{
			self.tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Proposals"

		self.tableView.separatorStyle = .none
		
//		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
		self.navigationItem.leftBarButtonItem = newBackButton
		self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.black], for:.normal)

		let addButton = UIBarButtonItem.init(title: "+", style: .done, target: self, action: #selector(addProposalHandler))
		self.navigationItem.rightBarButtonItem = addButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black], for:.normal)

		Fire.shared.getData("projects") { (data) in
			if let d = data as? [String:Any]{
				for(
				self.projects = d
			}
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
			return Array(self.projects.keys).count
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
			let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CreateProposalCell")
			cell.textLabel?.text = "Create Proposal"
			return cell
		}
		let keys:[String] = Array(self.projects.keys)
		let object:[String:Any] = (self.projects[ keys[indexPath.row] ] as? [String:Any])!
		let cell = UITableViewCell.init(style: .default, reuseIdentifier: "ProposalCell")
		cell.textLabel?.text = object["name"] as? String
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let keys:[String] = Array(self.projects.keys)
		let object:[String:Any] = (self.projects[ keys[indexPath.row] ] as? [String:Any])!
		let vc = ProjectTableViewController()
		Voila.shared.loadProject(key: keys[indexPath.row], object: object) {
			self.navigationController?.pushViewController(vc, animated: true)
		}
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

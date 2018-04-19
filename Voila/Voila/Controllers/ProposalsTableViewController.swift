//
//  ProposalsTableViewController.swift
//  Voila
//
//  Created by Robby on 10/20/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProposalsTableViewController: UITableViewController {
	
	var data:[Project] = []{
		didSet{
			self.tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Sent Proposals"
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke

		Fire.shared.getData("proposals") { (data) in
			Fire.shared.getData("confirmations") { (confirmData) in
				var proposalArray:[Project] = []
				if let d = data as? [String:Any]{
					for (key,value) in d{
						let project = Project(key: key, data: value as! [String : Any])
						proposalArray.append(project)
					}
				}
				self.data = proposalArray.sorted(by: { (a, b) -> Bool in
					return a.name < b.name
				})
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Style.shared.P60
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = DetailDetailTableViewCell(style: .value1, reuseIdentifier: "sent-proposal-cell")
		cell.isUserInteractionEnabled = false
		let project = self.data[indexPath.row]
		cell.textLabel?.text = project.name
		if let sentDate = project.proposalSent{
			cell.detailDetailTextLabel.text = Style.shared.dayStringForDate(Date(timeIntervalSince1970: TimeInterval(sentDate)))
		}
		return cell
    }

}

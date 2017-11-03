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
	
	var confirmations:[Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Sent Proposals"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.view.backgroundColor = Style.shared.whiteSmoke

		
		Fire.shared.getData("proposals") { (data) in
			Fire.shared.getData("confirmations") { (confirmData) in
				var confirmArray:[Bool] = []
				var proposalArray:[Project] = []
				if let d = data as? [String:Any]{
					for (key,value) in d{
						let project = Project(key: key, data: value as! [String : Any])
						proposalArray.append(project)
						if let confirmD = confirmData as? [String:Any]{
							if let didConfirm = confirmD[key]{
								confirmArray.append(true)
							} else{
								confirmArray.append(false)
							}
						} else{
							confirmArray.append(false)
						}
					}
				}
				self.confirmations = confirmArray
				self.data = proposalArray
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = DetailDetailTableViewCell(style: .value1, reuseIdentifier: "sent-proposal-cell")
		
		cell.isUserInteractionEnabled = false
		
		let project = self.data[indexPath.row]
		cell.textLabel?.text = project.name
		if let sentDate = project.proposalSent{
			print(sentDate)
//			cell.detailTextLabel?.text = Style.shared.dayStringForDate(Date(timeIntervalSince1970: TimeInterval(sentDate)))
			cell.detailDetailTextLabel.text = Style.shared.dayStringForDate(Date(timeIntervalSince1970: TimeInterval(sentDate)))
		}
		if self.confirmations.count > indexPath.row{
			switch self.confirmations[indexPath.row]{
			case true:
				cell.detailTextLabel?.text = "confirmed"
				cell.detailTextLabel?.textColor = .black
			case false:
				cell.detailTextLabel?.text = "not yet"
				cell.detailTextLabel?.textColor = Style.shared.highlight
			}
		}
		return cell
    }
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

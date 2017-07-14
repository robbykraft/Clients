//
//  AllRoomsTableViewController.swift
//  Voila
//
//  Created by Robby on 7/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class AllRoomsTableViewController: UITableViewController {
	
	var data:Project?{
		didSet{
			self.tableView.reloadData()
			if let d = self.data{
				self.roomTypesAndCounts = d.roomTypesAndCounts()
			}
		}
	}
	
	var roomTypesAndCounts:[String:Int]?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Add/Remove Rooms"
		
		self.tableView.separatorStyle = .none
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneHandler))
		self.navigationItem.rightBarButtonItem = newBackButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)
		
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Voila.shared.roomNames.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "RoomCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		
		let roomNameString = Voila.shared.roomNames[indexPath.row]
		cell.textLabel?.text = roomNameString
		
		if let types = self.roomTypesAndCounts{
			if let count = types[roomNameString]{
				cell.textLabel?.textColor = Style.shared.blue
				cell.detailTextLabel?.text = "\(count)"
			}
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let roomNameString = Voila.shared.roomNames[indexPath.row]
		if let types = self.roomTypesAndCounts{
			if let count = types[roomNameString]{
				self.roomTypesAndCounts![roomNameString] = count + 1
			} else{
				self.roomTypesAndCounts![roomNameString] = 1
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
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

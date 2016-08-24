//
//  ChallengesViewController.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ChallengesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var data: Lesson?
	
	let titleLabel:UILabel = UILabel()
	let percentLabel:UILabel = UILabel()
	
	let tableView = UITableView()
	
	var completedArray = [false, false, false]
	
	func updatePercent() {
		var numCompleted = 0
		for completed in completedArray {
			if(completed){
				numCompleted += 1
			}
		}
		switch numCompleted {
		case 0:
			percentLabel.text = "0%"
		case 1:
			percentLabel.text = "33%"
		case 2:
			percentLabel.text = "66%"
		case 3:
			percentLabel.text = "100%"
		default:
			percentLabel.text = "0%"
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.whiteColor()
		
		// header
		titleLabel.text = "TODAY'S SCORE"
		titleLabel.font = UIFont(name: SYSTEM_FONT, size: 30)
		titleLabel.textColor = UIColor.blackColor()
		titleLabel.sizeToFit()
		titleLabel.center = CGPointMake(self.view.center.x, 40)
		self.view.addSubview(titleLabel)

		percentLabel.text = "0%"
		percentLabel.font = UIFont(name: SYSTEM_FONT, size: 30)
		percentLabel.textColor = Style.shared.green
		percentLabel.textAlignment = .Center
		percentLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 40)
		percentLabel.center = CGPointMake(self.view.center.x, 75)
		self.view.addSubview(percentLabel)
		
		// shift tableview down
		let HEADER:CGFloat = 100.0
		self.view.addSubview(self.tableView)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.frame = CGRectMake(0, HEADER, self.view.frame.width, self.view.frame.height-HEADER)
    }

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 150
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = ChallengeTableViewCell()
		cell.completed = completedArray[indexPath.row]
		return cell
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if(completedArray[indexPath.row]){
			completedArray[indexPath.row] = false
		}
		else{
			completedArray[indexPath.row] = true
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.tableView.reloadData()
		self.updatePercent()
	}

}

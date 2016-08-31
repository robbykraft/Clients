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
	
	var challengeOfTheWeekText:String?
	
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
		
		if(data?.key != nil){
			let lessonKey:String = (data?.key!)!
			Fire.shared.updateUserWithKeyAndValue("challenges/\(lessonKey)", value: completedArray, completionHandler: nil)
		}
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.whiteColor()
		
		// header
		titleLabel.text = "TODAY'S SCORE"
		titleLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		titleLabel.textColor = UIColor.blackColor()
		self.view.addSubview(titleLabel)

		percentLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		percentLabel.textColor = Style.shared.green
		percentLabel.textAlignment = .Center
		self.view.addSubview(percentLabel)
		
		self.view.addSubview(self.tableView)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		getChallengeOfTheWeek()
		
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		titleLabel.sizeToFit()
		titleLabel.center = CGPointMake(self.view.center.x, titleLabel.frame.size.height*0.75)
		percentLabel.text = "%"
		percentLabel.sizeToFit()
		percentLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, percentLabel.frame.size.height)
		percentLabel.center = CGPointMake(self.view.center.x, titleLabel.center.y + titleLabel.frame.size.height)

		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
		let statusHeight:CGFloat = statusBarHeight()

		// shift tableview down
		let HEADER:CGFloat = percentLabel.center.y + percentLabel.frame.size.height * 0.6
		self.tableView.frame = CGRectMake(0, HEADER, self.view.frame.size.width, self.view.frame.size.height - navBarHeight - tabBarHeight - statusHeight - HEADER)
		
		print("completed")
		print(completedArray)
		updatePercent()
		
	}
	func getChallengeOfTheWeek(){
		Fire.shared.loadData("challenges/0/01") { (data) in
			self.challengeOfTheWeekText = data as? String
			self.tableView.reloadData()
		}
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if(IS_IPAD){
			return 260
		}
		return 150
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = ChallengeTableViewCell()
		cell.completed = completedArray[indexPath.row]
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = challengeOfTheWeekText
		case 1:
			cell.textLabel?.text = "Incorporate the quote of the day into a teaching lesson"
		case 2:
			cell.textLabel?.text = "Take some time to share the Lesson of the Day with one of your classes"
		default:
			cell.textLabel?.text = ""
		}
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

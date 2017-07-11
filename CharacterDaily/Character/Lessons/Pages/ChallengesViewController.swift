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
		
//		if(data?.key != nil){
//			let lessonKey:String = (data?.key!)!
//			Fire.shared.updateUserWithKeyAndValue("challenges/\(lessonKey)", value: completedArray as AnyObject, completionHandler: nil)
//		}
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		
		// header
		titleLabel.text = "TODAY'S SCORE"
		titleLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		titleLabel.textColor = UIColor.black
		self.view.addSubview(titleLabel)

		percentLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		percentLabel.textColor = Style.shared.green
		percentLabel.textAlignment = .center
		self.view.addSubview(percentLabel)
		
		self.view.addSubview(self.tableView)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		getChallengeOfTheWeek()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		titleLabel.sizeToFit()
		titleLabel.center = CGPoint(x: self.view.center.x, y: titleLabel.frame.size.height*0.75)
		percentLabel.text = "%"
		percentLabel.sizeToFit()
		percentLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: percentLabel.frame.size.height)
		percentLabel.center = CGPoint(x: self.view.center.x, y: titleLabel.center.y + titleLabel.frame.size.height)

		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
		let statusHeight:CGFloat = statusBarHeight()

		// shift tableview down
		let HEADER:CGFloat = percentLabel.center.y + percentLabel.frame.size.height * 0.6
		self.tableView.frame = CGRect(x: 0, y: HEADER, width: self.view.frame.size.width, height: self.view.frame.size.height - navBarHeight - tabBarHeight - statusHeight - HEADER)
		
		updatePercent()
		
	}
	func getChallengeOfTheWeek(){
		let calendar = Calendar.current
		
		let dateComponent = (calendar as NSCalendar).components([.weekOfMonth], from: (data?.date!)! as Date )
		let weekNumber:Int = dateComponent.weekOfMonth!
		
		let pillarNumber = data?.pillar
		if(pillarNumber != nil){
			let pillarInt:Int = pillarNumber!
			Fire.shared.loadData("challenges/\(pillarInt)/\(weekNumber)") { (data) in
				if(data != nil){
					self.challengeOfTheWeekText = data as? String
					self.tableView.reloadData()
				}
				else{
					self.challengeOfTheWeekText = "(No Unique Challenge this week!)"
					self.tableView.reloadData()
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 260
		}
		return 150
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = ChallengeTableViewCell()
		cell.completed = completedArray[(indexPath as NSIndexPath).row]
		switch (indexPath as NSIndexPath).row {
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
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(completedArray[(indexPath as NSIndexPath).row]){
			completedArray[(indexPath as NSIndexPath).row] = false
		}
		else{
			completedArray[(indexPath as NSIndexPath).row] = true
		}
		tableView.deselectRow(at: indexPath, animated: true)
		self.tableView.reloadData()
		self.updatePercent()
	}

}

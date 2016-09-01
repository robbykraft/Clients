//
//  ScoreViewController.swift
//  Character
//
//  Created by Robby on 8/31/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ScoreViewController: UITableViewController {
	
	var maxChallenges:Int? {
		didSet{
			self.tableView.reloadData()
		}
	}
	
	var percentArray:[String] = [ "0%", "33%", "66%", "100%" ]
	
	var keyArray:[NSDate]?
	
	var data: [ NSDate:Int ]? {
		didSet{
			if(data != nil){
				self.keyArray = Array( (data?.keys)! )
			}
			self.tableView.reloadData()
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.title = "MY SCORE"
		
		self.tableView.separatorColor = UIColor.clearColor();

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);

		Character.shared.getMyScore({ (dateDictionary) in
			self.data = dateDictionary
		})
		
		Fire.shared.getUser { (uid, userData) in
			if(userData != nil && userData!["grade"] != nil){
				let gradeArray:[Int] = userData!["grade"] as! [Int]
				
				if(gradeArray.contains(0) && gradeArray.contains(1) && gradeArray.contains(2) && gradeArray.contains(3)){
					self.maxChallenges = 12
				}
				else{
					self.maxChallenges = 3
				}
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if cell.respondsToSelector(Selector("setSeparatorInset:")){
			cell.separatorInset = UIEdgeInsetsZero
		}
		if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
			cell.preservesSuperviewLayoutMargins = false
		}
		if cell.respondsToSelector(Selector("setLayoutMargins:")){
			cell.layoutMargins = UIEdgeInsetsZero
		}
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if(self.data != nil){
			return 1
		}
		return 0
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if(IS_IPAD){
			return 80
		}
		return 60;
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.data?.count)!
	}
	
	func daySuffix(dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "# Completed:"
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .Value1, reuseIdentifier: "scoreTableViewCell")
		
	

		if(keyArray != nil){

			// date
			let date = keyArray![indexPath.row]
			let dateComponents:NSDateComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: date)
			let dayString = "\(dateComponents.day)" + daySuffix(dateComponents.day)
			let dateText: String = monthAbbrevs[dateComponents.month - 1] + " " + dayString
			cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
			cell.textLabel?.text = dateText

			// percent
//			let completedArray:[Bool]? = self.data![date]
//			if(completedArray != nil){
//				var count:Int = 0
//				for entry in completedArray!{
//					if entry == true{
//						count += 1
//					}
//				}
//				cell.detailTextLabel?.text = percentArray[count]
//			}
			cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			let completed:Int? = self.data![date]
			if(completed != nil){
				switch completed! {
				case 0:
					cell.detailTextLabel?.textColor = UIColor(white: 0.85, alpha: 1.0)
					break
					
				case 1:
					cell.detailTextLabel?.textColor = Style.shared.gray
					break
					
				case 2:
					cell.detailTextLabel?.textColor = Style.shared.gray
					break
					
				default:
					cell.detailTextLabel?.textColor = Style.shared.green
					break
				}
//				if(maxChallenges != nil){
//					cell.detailTextLabel?.text = "\(completed!) / \(maxChallenges!)"
//				}
//				else{
					cell.detailTextLabel?.text = "\(completed!)"
//				}
			}
		}
		
		
//		let text:String = objectForRow.title!
//		
//		// date
//
//		cell.gradeLevel = objectForRow.grade!
//		
//		cell.titleText = text.uppercaseString
//		cell.dateText = dateText.uppercaseString
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: false)
	}
	
	

}

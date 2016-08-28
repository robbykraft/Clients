//
//  LessonsTableViewController.swift
//  Lessons
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

let monthAbbrevs = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]

class LessonsTableViewController: UITableViewController {
	
	var data: [Lesson]? {
		didSet{
			self.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.title = "ALL LESSONS"

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
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
		return 120;
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
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = LessonsTableViewCell.init(style: .Value1, reuseIdentifier: "tableCell")
		
		var text: String = "Title"
		
		let deltaDate = NSDateComponents()
		deltaDate.day = indexPath.row
		let cellDate:NSDate = NSCalendar.currentCalendar().dateByAddingComponents(deltaDate, toDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
		let dateComponents:NSDateComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: cellDate)
		let dayString = "\(dateComponents.day)" + daySuffix(dateComponents.day)
		let dateText: String = monthAbbrevs[dateComponents.month - 1] + " " + dayString
		
		let objectForRow = self.data![indexPath.row]
		text = objectForRow.title!
		let imageFilename:String = objectForRow.image!
		Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, requiredDownload) in
			cell.imageView?.image = image
			if(requiredDownload){
				self.tableView.reloadData()
			}
		})
//		cell.imageView?.imageFromStorageBucket(imageFile)
		
		cell.gradeLevel = objectForRow.grade!

		cell.titleText = text.uppercaseString
		cell.dateText = dateText.uppercaseString
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let nextObject = self.data![indexPath.row]
		
		let vc: LessonTableViewController = LessonTableViewController()
		vc.data = nextObject
//		let pillarName = nextObject["pillar"]!!
//		vc.title = String(pillarName).uppercaseString
		vc.title = "TRUSTWORTHINESS"
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

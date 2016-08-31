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
	
	// FILTER GRADE LEVELS
	var showFilter:Bool = false
	var filteredData: [Lesson]?
	var filter:Int?{
		didSet{
			if(filter != nil){
				filteredData = filterLessons(filter!)
			}
			self.tableView.reloadData()
		}
	}
	func filterLessons(filterBy:Int) -> [Lesson] {
		var array:[Lesson] = []
		for lesson in data! {
			if lesson.grade == filterBy{
				array.append(lesson)
			}
		}
		return array
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.title = "ALL LESSONS"

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
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
			return 200
		}
		return 120;
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(showFilter && filter != nil){
			return (self.filteredData?.count)!
		}
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
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if(showFilter == false){
			return nil
		}
		var viewH:CGFloat = 34
		if(IS_IPAD){
			viewH = 60
		}
		
		let view = UIView()
		view.backgroundColor = Style.shared.darkGray
		
		let buttonW = self.view.frame.size.width * 0.8
		let button = UIButton()
		button.backgroundColor = UIColor.clearColor()
		button.frame = CGRectMake((self.view.frame.size.width - buttonW) * 0.5, 0, buttonW, viewH)
		button.addTarget(self, action: #selector(filterButtonHandler), forControlEvents: .TouchUpInside)

		let filterLabel = UILabel()
		filterLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		filterLabel.textColor = Style.shared.whiteSmoke
		filterLabel.frame = CGRectMake(0, 0, self.view.frame.size.width*0.5 - 10, viewH)
		filterLabel.textAlignment = .Right
		filterLabel.text = "Filter:"

		let gradeLabel = UILabel()
		gradeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		gradeLabel.textColor = UIColor.whiteColor()
		gradeLabel.frame = CGRectMake(self.view.frame.size.width*0.5, 0, self.view.frame.size.width*0.5, viewH)
		gradeLabel.textAlignment = .Left
		if(filter == nil){
			gradeLabel.text = "All Grades"
		} else{
			gradeLabel.text = Character.shared.gradeNames[filter!]
		}
		
		view.addSubview(filterLabel)
		view.addSubview(gradeLabel)
		view.addSubview(button)
		return view
	}
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if(showFilter == true){
			if(IS_IPAD){
				return 60
			}
			return 34
		}
		return 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = LessonsTableViewCell.init(style: .Value1, reuseIdentifier: "tableCell")
		
		var objectForRow:Lesson
		if(showFilter && filter != nil){
			objectForRow = self.filteredData![indexPath.row]
		} else{
			objectForRow = self.data![indexPath.row]
		}
		
		let text:String = objectForRow.title!
		
		// date
		let dateComponents:NSDateComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: objectForRow.date!)
		let dayString = "\(dateComponents.day)" + daySuffix(dateComponents.day)
		let dateText: String = monthAbbrevs[dateComponents.month - 1] + " " + dayString

		// image
		let imageFilename:String = objectForRow.image!
		Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, requiredDownload) in
			cell.imageView?.image = image
			if(requiredDownload){
				self.tableView.reloadData()
			}
		})
		
		cell.gradeLevel = objectForRow.grade!

		cell.titleText = text.uppercaseString
		cell.dateText = dateText.uppercaseString
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var nextObject:Lesson
		if(showFilter && filter != nil){
			nextObject = self.filteredData![indexPath.row]
		} else{
			nextObject = self.data![indexPath.row]
		}
		
		let vc: LessonTableViewController = LessonTableViewController()
		vc.data = nextObject
//		let pillarName = nextObject["pillar"]!!
//		vc.title = String(pillarName).uppercaseString
		vc.title = "TRUSTWORTHINESS"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
	func filterButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .Default) { (action) in
			self.filter = 0
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .Default) { (action) in
			self.filter = 1
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .Default) { (action) in
			self.filter = 2
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .Default) { (action) in
			self.filter = 3
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .Default) { (action) in
			self.filter = nil
		}
		let cancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		alert.addAction(action4)
		alert.addAction(action5)
		alert.addAction(cancel)

		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.presentViewController(alert, animated: true, completion: nil)
	}

}

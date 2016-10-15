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
	func filterLessons(_ filterBy:Int) -> [Lesson] {
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

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
			cell.separatorInset = UIEdgeInsets.zero
		}
		if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
			cell.preservesSuperviewLayoutMargins = false
		}
		if cell.responds(to: #selector(setter: UIView.layoutMargins)){
			cell.layoutMargins = UIEdgeInsets.zero
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if(self.data != nil){
			return 1
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 200
		}
		return 120;
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(showFilter && filter != nil){
			return (self.filteredData?.count)!
		}
		return (self.data?.count)!
	}
	
	func daySuffix(_ dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
		button.backgroundColor = UIColor.clear
		button.frame = CGRect(x: (self.view.frame.size.width - buttonW) * 0.5, y: 0, width: buttonW, height: viewH)
		button.addTarget(self, action: #selector(filterButtonHandler), for: .touchUpInside)

		let filterLabel = UILabel()
		filterLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		filterLabel.textColor = Style.shared.whiteSmoke
		filterLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.5 - 10, height: viewH)
		filterLabel.textAlignment = .right
		filterLabel.text = "Filter:"

		let gradeLabel = UILabel()
		gradeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		gradeLabel.textColor = UIColor.white
		gradeLabel.frame = CGRect(x: self.view.frame.size.width*0.5, y: 0, width: self.view.frame.size.width*0.5, height: viewH)
		gradeLabel.textAlignment = .left
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
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if(showFilter == true){
			if(IS_IPAD){
				return 60
			}
			return 34
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = LessonsTableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		
		var objectForRow:Lesson
		if(showFilter && filter != nil){
			objectForRow = self.filteredData![(indexPath as NSIndexPath).row]
		} else{
			objectForRow = self.data![(indexPath as NSIndexPath).row]
		}
		
		let text:String = objectForRow.title!
		
		// date
		let dateComponents:DateComponents = (Calendar.current as NSCalendar).components([.month, .day], from: objectForRow.date! as Date)

		// image
		let imageFilename:String = objectForRow.image!
		Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, requiredDownload) in
			cell.imageView?.image = image
			if(requiredDownload){
				self.tableView.reloadData()
			}
		})
		
		cell.gradeLevel = objectForRow.grade!
		cell.titleText = text.uppercased()
		if let dateInt = dateComponents.day {
			let dayString = "\(dateInt)" + daySuffix(dateInt)
			let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
			cell.dateText = dateText.uppercased()
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var nextObject:Lesson
		if(showFilter && filter != nil){
			nextObject = self.filteredData![(indexPath as NSIndexPath).row]
		} else{
			nextObject = self.data![(indexPath as NSIndexPath).row]
		}
		
		let vc: LessonTableViewController = LessonTableViewController()
		vc.data = nextObject
		vc.isLoadingLessons = false
//		let pillarName = nextObject["pillar"]!!
//		vc.title = String(pillarName).uppercaseString
		vc.title = "TRUSTWORTHINESS"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
	func filterButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .default) { (action) in
			self.filter = 0
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .default) { (action) in
			self.filter = 1
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .default) { (action) in
			self.filter = 2
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .default) { (action) in
			self.filter = 3
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .default) { (action) in
			self.filter = nil
		}
		let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
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
		self.present(alert, animated: true, completion: nil)
	}

}

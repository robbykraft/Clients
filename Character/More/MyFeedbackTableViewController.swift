//
//  FeedbackViewController.swift
//  Character
//
//  Created by Robby on 8/27/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class MyFeedbackTableViewController: UITableViewController {
	
	var data: [[String:Any]]? {
		// data is an array of objects, each object with keys and values:
		//   createdAt  (unix time stamp)  creation date
		//   user       (string)           user database id
		//   text       (string)           feedback body text
		didSet{
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.title = "MY FEEDBACK"
		
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
		if let d = self.data{
			return d.count
		}
		return 0
	}
	
	func daySuffix(_ dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = LessonsTableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		
		if let d = self.data{
			let rowData:[String:Any] = d[indexPath.row]
			
			if let feedbackBody = rowData["text"] as? String{
				cell.textLabel?.text = feedbackBody
			}
			
			// date
			if let unixTime = rowData["createdAt"] as? Double{
				let date:Date = Date.init(timeIntervalSince1970: unixTime)
				let dateComponents:DateComponents = (Calendar.current as NSCalendar).components([.month, .day], from: date as Date)
				if let dateInt = dateComponents.day {
					let dayString = "\(dateInt)" + daySuffix(dateInt)
					let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
					cell.dateText = dateText.uppercased()
				}
			}
			
//				cell.titleText = text.uppercased()
			
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if let d = self.data{
			let rowData:[String:Any] = d[indexPath.row]

//			let vc: LessonTableViewController = LessonTableViewController()
//			vc.data = nextObject
//			vc.isLoadingLessons = false
//			vc.title = ""
//			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
}

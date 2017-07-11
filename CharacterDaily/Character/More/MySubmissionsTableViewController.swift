//
//  FeedbackViewController.swift
//  Character
//
//  Created by Robby on 8/27/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

// data is an array of objects, each object with keys and values:
//   createdAt  (unix time stamp)  creation date
//   user       (string)           user database id
//   text       (string)           feedback body text


class MySubmissionsTableViewController: UITableViewController {
	
	var data: [[String:Any]]? {
		// each entry should have a key and value of 
		// "type":"feedback" / "lesson" / "quote"
		// "key" : the pointer to the object in the database
		didSet{
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.title = "MY SUBMISSIONS"
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
		
		getMySubmittedContent()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	func getMySubmittedContent(){
		var myFeedback:[[String:Any]] = []
		let myUsernameKey:String = Fire.shared.myUID!
		self.data = []
		Fire.shared.loadData("feedback") { (data) in
			if let feedbackList = data as? [String:Any]{
				let keys = Array(feedbackList.keys)
				for k in keys{
					if let feedbackEntry = feedbackList[k] as? [String:Any]{
						if let feedbackUser = feedbackEntry["user"] as? String{
							if feedbackUser == myUsernameKey{
								var newEntry = feedbackEntry
								newEntry["type"] = "feedback"
								newEntry["key"] = k
								myFeedback.append(newEntry)
							}
						}
					}
				}
			}
			self.data?.append(contentsOf: myFeedback)
		}
		var myLessons:[[String:Any]] = []
		Fire.shared.loadData("lessons") { (data) in
			if let lessonList = data as? [String:Any]{
				let keys = Array(lessonList.keys)
				for k in keys{
					if let lessonEntry = lessonList[k] as? [String:Any]{
						if let lessonCreatedBy = lessonEntry["submitted"] as? String{
							if lessonCreatedBy == myUsernameKey{
								var newEntry = lessonEntry
								newEntry["type"] = "lesson"
								newEntry["key"] = k
								myLessons.append(newEntry)
//								print(newEntry)
							}
						}
					}
				}
			}
			self.data?.append(contentsOf: myLessons)
		}
		
		var myQuotes:[[String:Any]] = []
		Fire.shared.loadData("quotes") { (data) in
			if let lessonList = data as? [String:Any]{
				let keys = Array(lessonList.keys)
				for k in keys{
					if let lessonEntry = lessonList[k] as? [String:Any]{
						if let lessonCreatedBy = lessonEntry["submitted"] as? String{
							if lessonCreatedBy == myUsernameKey{
								var newEntry = lessonEntry
								newEntry["type"] = "quote"
								newEntry["key"] = k
								myQuotes.append(newEntry)
//								print(newEntry)
							}
						}
					}
				}
			}
			self.data?.append(contentsOf: myQuotes)
		}

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
		let cell = DateTableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		
		if let d = self.data{
			let rowData:[String:Any] = d[indexPath.row]
			
			// IF QUOTE
			if let quoteText = rowData["body"] as? String{
				if let quoteAuthor = rowData["author"] as? String{
					cell.dateText = quoteAuthor.uppercased()
				}
				cell.textLabel?.text = quoteText
			}
			
			
			
			if let body = rowData["text"] as? String{
				cell.textLabel?.text = body
			}
			
			if let title = rowData["title"] as? String{
				cell.textLabel?.text = title
			}

			
			if let type = rowData["type"] as? String{
				cell.detailLabel.text = type.uppercased()
			}
	

			
//			if let feedbackTarget = rowData["target"] as? [String:Any]{
//				if let feedbackType = feedbackTarget["type"] as? String{
//					cell.detailLabel.text = feedbackType
//				}
//			}
			
			// date
			if let unixTime = rowData["createdAt"] as? Double{
				let date:Date = Date.init(timeIntervalSince1970: unixTime)
				let dateComponents:DateComponents = (Calendar.current as NSCalendar).components([.month, .day], from: date as Date)
				if let dateInt = dateComponents.day {
					let dayString = "\(dateInt)" + daySuffix(dateInt)
					let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
					cell.dateText = dateText.uppercased()
				}
			} else{
				if let pillar = rowData["pillar"] as? Int{
					if(pillar < Character.shared.pillarNames.count){
						cell.dateText = Character.shared.pillarNames[pillar].uppercased()
					}
				}
			}
			
//				cell.titleText = text.uppercased()
			
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if let d = self.data{
			let rowData:[String:Any] = d[indexPath.row]
			let type = rowData["type"] as? String
			if type == "feedback"{
				let _ = rowData["key"] as? String
				var createdAt = rowData["createdAt"] as? Double
				if(createdAt == nil) { createdAt = 0.0; }
				let vc = FeedbackViewController()
				vc.data = rowData
				self.navigationController?.pushViewController(vc, animated: true)
				
			}
			if type == "lesson"{
				let key = rowData["key"] as? String
				var createdAt = rowData["createdAt"] as? Double
				if(createdAt == nil) { createdAt = 0.0; }
				if let lessonKey = key{
					let lesson = Lesson()
					lesson.setFromDatabase(lessonKey: lessonKey, quoteKey: "", behaviorKey: "", date: Date.init(timeIntervalSince1970: createdAt!), { (success, lesson) in
						let vc = CreateLessonViewController()
						vc.showFakeNavBar = false
						vc.data = lesson
						vc.updatingLessonKey = lessonKey
						self.navigationController?.pushViewController(vc, animated: true)
					})
				}
			}
			if type == "quote"{
				let key = rowData["key"] as? String
				var createdAt = rowData["createdAt"] as? Double
				if(createdAt == nil) { createdAt = 0.0; }
				if let quoteKey = key{
					let lesson = Lesson()
					lesson.setFromDatabase(lessonKey: "", quoteKey: quoteKey, behaviorKey: "", date: Date.init(timeIntervalSince1970: createdAt!), { (success, quote) in
						let vc = CreateQuoteViewController()
						vc.showFakeNavBar = false
						vc.data = ["author":lesson.quoteAuthor!, "text":lesson.quote!]
						self.navigationController?.pushViewController(vc, animated: true)
					})
				}
			}

			
		}
		
//		if let d = self.data{
//			let rowData:[String:Any] = d[indexPath.row]

//			let vc: LessonTableViewController = LessonTableViewController()
//			vc.data = nextObject
//			vc.isLoadingLessons = false
//			vc.title = ""
//			self.navigationController?.pushViewController(vc, animated: true)
//		}
	}
	
}

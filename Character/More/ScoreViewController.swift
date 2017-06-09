//
//  ScoreViewController.swift
//  Character
//
//  Created by Robby on 8/31/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ScoreViewController: UITableViewController {
	
	var percentArray:[String] = [ "0%", "33%", "66%", "100%" ]
	
	var keyArray:[Date]?
	
	var score:[Date:[[String:Any]]]?
	
	var data: [ Date:[[Bool]] ]? {
		didSet{
//			if(data != nil){
//				let unsorted = Array( (data?.keys)! )
//				self.keyArray = unsorted.sorted(by: { $0.compare($1) == ComparisonResult.orderedAscending })
////				self.keyArray = unsorted.sort({ $0.order < $1.order })
//			}
			self.tableView.reloadData()
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.title = "MY SCORE"
		
		self.tableView.separatorColor = UIColor.clear;

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		Character.shared.getMyScore({ (dateDictionary) in
//			self.data = dateDictionary
//		})
		if let schedule = Schedule.shared.schoolYear{
			self.keyArray = Array(schedule.keys)
			self.keyArray?.sort()
			self.keyArray?.reverse()
			
			// get my challenges
			Fire.shared.getUser { (uid, data) in
				if let userData = data{
					var challenges = userData["challenges"] as? [String:Any]
//					print("challenges")
					if(challenges == nil){
						challenges = [:]
					}
//					print(challenges!)
					self.score = [:]
					for date in self.keyArray!{
						self.score?[date] = []
						if let thisDay:[[String:Any]] = schedule[date]{
							for i in 0..<thisDay.count{
								var lesson = false
								var quote = false
								var behavior = false
								var pledge = false
								if let lKey:String = thisDay[i]["lesson"] as? String{
									if(challenges?[lKey] != nil){
										lesson = (challenges?[lKey] as? Bool)!
									}
								}
								if let qKey:String = thisDay[i]["quote"] as? String{
									if(challenges?[qKey] != nil){
										quote = (challenges?[qKey] as? Bool)!
									}
								}
								let dateInt:String = String(Int(date.timeIntervalSince1970))
								if(challenges?[dateInt] != nil){
									if let challengeGrades:[String:Any] = challenges?[dateInt] as? [String:Any]{
										if let more:[String:Bool] = challengeGrades[String(describing:i)] as? [String:Bool]{
											if(more["behavior"] != nil){
												behavior = more["behavior"]!
											}
											if(more["pledge"] != nil){
												pledge = more["pledge"]!
											}
										}
									}
//									let more:[String:Bool] = challenges?[dateInt] as! [String:Bool]
//									if(more["behavior"] != nil){
//										behavior = more["behavior"]!
//									}
//									if(more["pledge"] != nil){
//										pledge = more["pledge"]!
//									}
								}
								self.score?[date]?.append( ["lesson":lesson,
								                            "quote":quote,
								                            "behavior":behavior,
								                            "pledge":pledge] )
							}
						}
					}
//					print(self.score!)
					self.tableView.reloadData()
				}
			}
		}

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
		if(self.keyArray != nil){
			return 1
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 110
		}
		return 80;
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return (self.data?.count)!
		return (self.keyArray?.count)!
	}
	
	func daySuffix(_ dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Lesson - Quote - Behavior - " + Character.shared.pledgeTypeName.capitalized
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = ScoreTableViewCell.init(style: .default, reuseIdentifier: "scoreTableViewcell")
		
		if(keyArray != nil){
			var GMTCalendar = Calendar.current
			GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!

			// date
			let date = keyArray![(indexPath as NSIndexPath).row]
			let dateComponents:DateComponents = (GMTCalendar as NSCalendar).components([.month, .day], from: date as Date)
			if let dateInt = dateComponents.day {
				let dayString = "\(dateInt)" + daySuffix(dateInt)
				let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
				cell.dateText = dateText.uppercased()
			}
			
			let todayScore = self.score?[date]
			if(todayScore != nil){
				if Character.shared.myGradeLevel.count == 1{
					let myGradeScore:[String:Bool] = todayScore![Character.shared.myGradeLevel.first!] as! [String:Bool]
					if(myGradeScore["lesson"] == true){   cell.scores[0].text = "✔︎" }
					if(myGradeScore["quote"] == true){    cell.scores[1].text = "✔︎" }
					if(myGradeScore["behavior"] == true){ cell.scores[2].text = "✔︎" }
					if(myGradeScore["pledge"] == true){   cell.scores[3].text = "✔︎" }
					
				} else{
					var lCount = 0
					var qCount = 0
					var bCount = 0
					var pCount = 0
					for grade in Character.shared.myGradeLevel {
						let myGradeScore:[String:Bool] = todayScore![grade] as! [String:Bool]
						
						if(myGradeScore["lesson"] == true){ lCount += 1 }
						if(myGradeScore["quote"] == true){ qCount += 1 }
						if(myGradeScore["behavior"] == true){ bCount += 1 }
						if(myGradeScore["pledge"] == true){ pCount += 1 }
						
					}
					if(lCount > 0){ cell.scores[0].text = "✔︎:" + String(lCount)}
					if(qCount > 0){ cell.scores[1].text = "✔︎:" + String(qCount)}
					if(bCount > 0){ cell.scores[2].text = "✔︎:" + String(bCount)}
					if(pCount > 0){ cell.scores[3].text = "✔︎:" + String(pCount)}
				}
			}
			
			return cell

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
			cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
			cell.detailTextLabel?.textColor = UIColor.black
			let completed:[[Bool]]? = self.data![date]

			var totalCount:Int = 0
			var yesCount:Int = 0
			var noCount:Int = 0
			
			if(completed != nil){
				var emojiString:String = ""
				for boolArray in completed!{
					for entry in boolArray{
						if(entry){
							emojiString.append("✔︎")
							yesCount += 1
						} else{
							emojiString.append("✘")
							noCount += 1
						}
						totalCount += 1
					}
				}

				if(totalCount <= 3){
					cell.detailTextLabel?.text = emojiString
				} else{
					cell.detailTextLabel?.text = "\(yesCount):✔︎  \(noCount):✘"
				}
			}
		}
		
		cell.selectionStyle = .none
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	

}

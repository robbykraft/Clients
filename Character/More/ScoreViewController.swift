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
	
	var keyArray:[Date]?
	
	var data: [ Date:Int ]? {
		didSet{
			if(data != nil){
				let unsorted = Array( (data?.keys)! )
				self.keyArray = unsorted.sorted(by: { $0.compare($1) == ComparisonResult.orderedAscending })
//				self.keyArray = unsorted.sort({ $0.order < $1.order })
			}
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
			return 80
		}
		return 60;
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "# Completed:"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "scoreTableViewCell")
		
	

		if(keyArray != nil){

			// date
			let date = keyArray![(indexPath as NSIndexPath).row]
			let dateComponents:DateComponents = (Calendar.current as NSCalendar).components([.month, .day], from: date)

			cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)

			if let dateInt = dateComponents.day {
				let dayString = "\(dateInt)" + daySuffix(dateInt)
				let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
				cell.textLabel?.text = dateText
			}

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
		
		
		cell.selectionStyle = .none
		
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	

}

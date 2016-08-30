//
//  LessonTableViewController.swift
//  Lessons
//
//  Created by Robby on 8/12/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonTableViewController: UITableViewController {

	var data: Lesson?{
		didSet{
			self.tableView.reloadData()
			if(data?.key != nil){
				getCompletedChallenges((data?.key)!)
			}
		}
	}
	
	var completedChallengeArray:[Bool] = [false, false, false]{
		didSet{
			var count:Int = 0
			for each in completedChallengeArray{
				if(each){
					count += 1
				}
			}
			self.numChallengesCompleted = count
		}
	}
	var numChallengesCompleted:Int = 0{
		didSet{
			self.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.tableView.separatorColor = UIColor.clearColor();
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if(data != nil && data?.key != nil){
			getCompletedChallenges((data?.key)!)
		}
	}
	
	func getCompletedChallenges(lessonKey:String){
		Fire.shared.getUser { (uid, userData) in
			if(userData != nil){
				if(userData!["challenges"] != nil){
					let challenges = userData!["challenges"] as! [String:[Bool]]
					if(challenges[lessonKey] != nil){
						let challengeArray:[Bool] = challenges[lessonKey]!
						self.completedChallengeArray = challengeArray
					}
				}
			}
		}
	}
	

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if(data == nil){
			return 0
		}
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(data != nil){
			return 4
		}
		return 0
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 180
	}

	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
		switch indexPath.row {
		case 0:
			let vc: LessonViewController = LessonViewController()
			vc.data = self.data
			vc.title = "DAILY LESSON"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 1:
			let vc: QuoteViewController = QuoteViewController()
			vc.data = self.data
			vc.title = "DAILY QUOTE"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 2:
			let vc: ChallengesViewController = ChallengesViewController()
			vc.data = self.data
			vc.completedArray = self.completedChallengeArray
			vc.title = "DAILY CHALLENGE"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 3:
			let vc: PrayerViewController = PrayerViewController()
			vc.title = "DAILY PRAYER"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		default:
			break
		}
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			return lessonCellWithData(data)
		case 1:
			return quoteCellWithData(data)
		case 2:
			return challengesCellWithData(data)
		case 3:
			return prayerCellWithData(data)
		default:
			return UITableViewCell()
		}
    }
	
	func lessonCellWithData(data:Lesson?) -> LessonTableViewCell {
		let cell = LessonTableViewCell()
		cell.title = data?.title?.uppercaseString
		let imageFilename:String = (data?.image!)!
		Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, didRequireDownload) in
			cell.imageView?.image = image
			if(didRequireDownload){
				self.tableView.reloadData()
			}
		})
		return cell
	}
	
	func quoteCellWithData(data:Lesson?) -> QuoteTableViewCell {
		let cell = QuoteTableViewCell()
		cell.textLabel?.text = data?.quote!
		return cell
	}

	func challengesCellWithData(data:Lesson?) -> ChallengesTableViewCell {
		let cell = ChallengesTableViewCell()
		cell.numberCompleted = numChallengesCompleted
		return cell
	}
	
	func prayerCellWithData(data:Lesson?) -> PrayerTableViewCell {
		let cell = PrayerTableViewCell()
		cell.textLabel?.text = "Dear God,"
//		cell.textLabel?.text = "Dear God,\n \nThank you for this new day.\nHelp me to be a person of character and follow Your way,\n \nto be worthy of trust,\nto be respectful and responsible, doing what I must.\n \nHelp me to act with fairness, show that I care,\nbe a good citizen, and always live this prayer.\n \nAmen."
		return cell
	}

}

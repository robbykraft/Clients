//
//  LessonTableViewController.swift
//  Lessons
//
//  Created by Robby on 8/12/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonTableViewController: UITableViewController {
	
	let noLessonCoverView = UIView()
	
	let loadingLessonsCoverView = UIView()
	
	var isLoadingLessons: Bool?{
		didSet{
			if(isLoadingLessons)!{
				if(!loadingLessonsCoverView.isDescendant(of: self.view)){
					self.view.addSubview(loadingLessonsCoverView)
				}
			}else{
				loadingLessonsCoverView.removeFromSuperview()
			}
		}
	}

	var data: Lesson?{
		didSet{
			self.tableView.reloadData()
//			if(data?.key != nil){
//				getCompletedChallenges((data?.key)!)
//			}
			
			if(data != nil){
				if let pillarNumber = data?.pillar{
					self.navigationItem.title = Character.shared.pillarNames[pillarNumber].uppercased()
//					self.title = Character.shared.pillarNames[pillarNumber].uppercased()
//					self.tabBarItem.title = nil;
				}
			}
			
			if(data == nil){
				self.view.addSubview(noLessonCoverView)
				self.title = ""
			}
			else{
				noLessonCoverView.removeFromSuperview()
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
		
		self.buildChildViews()
		if(!noLessonCoverView.isDescendant(of: self.view)){
			self.view.addSubview(noLessonCoverView)
		}
		if(!loadingLessonsCoverView.isDescendant(of: self.view)){
			self.view.addSubview(loadingLessonsCoverView)
		}
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.tableView.separatorColor = UIColor.clear;
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

//		if(data != nil && data?.key != nil){
//			getCompletedChallenges((data?.key)!)
//		}
	}
	
	func buildChildViews(){
		
		// make "No Lesson Today" view
		noLessonCoverView.frame = self.view.bounds
		noLessonCoverView.backgroundColor = UIColor.clear
		let iconImageView = UIImageView()
		iconImageView.image = UIImage(named: "icon")
		iconImageView.alpha = 0.05
		iconImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.75, height: self.view.frame.size.width*0.75)
		iconImageView.center = CGPoint(x: self.view.center.x, y: (self.view.frame.size.height-44) * 0.33)
		noLessonCoverView.addSubview(iconImageView)
		let noLessonLabel = UILabel()
		noLessonLabel.text = "NO LESSON TODAY"
		noLessonLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P40)
		noLessonLabel.sizeToFit()
		if(noLessonLabel.frame.size.width > self.view.frame.size.width){
			noLessonLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
			noLessonLabel.sizeToFit()
		}
		noLessonLabel.center = CGPoint(x: self.view.center.x, y: iconImageView.center.y + iconImageView.frame.size.height * 0.4)
		noLessonLabel.textColor = UIColor.black
		noLessonLabel.alpha = 0.05
		noLessonCoverView.addSubview(noLessonLabel)
		
		// make "Loading Lessons" view
		loadingLessonsCoverView.frame = self.view.bounds
		loadingLessonsCoverView.backgroundColor = Style.shared.whiteSmoke//UIColor(white: 0.0, alpha: 0.1)
		let loadingWindow = UIView()
		loadingWindow.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width*CGFloat(0.5), height: self.view.bounds.size.width*CGFloat(0.5))
		loadingWindow.layer.cornerRadius = self.view.bounds.size.width*0.05
		loadingWindow.clipsToBounds = true
		loadingWindow.layer.masksToBounds = true
		loadingWindow.backgroundColor = Style.shared.darkGray
		loadingWindow.center = CGPoint(x: loadingLessonsCoverView.center.x, y: loadingLessonsCoverView.center.y - (44 + 12)*0.5 )
		loadingLessonsCoverView.addSubview(loadingWindow)
		let loadingLabel = UILabel()
		loadingLabel.text = "LOADING"
		loadingLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		loadingLabel.textColor = UIColor.white
		loadingLabel.sizeToFit()
		loadingLabel.center = CGPoint(x: loadingWindow.frame.size.width*0.5, y: loadingWindow.frame.size.height*0.5 + 30)
		loadingWindow.addSubview(loadingLabel)
		let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
		activityView.startAnimating()
		activityView.center = CGPoint(x: loadingWindow.frame.size.width*0.5, y: loadingWindow.frame.size.height*0.5 - 30)
		loadingWindow.addSubview(activityView)
	}
	
	func getCompletedChallenges(_ lessonKey:String){
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

    override func numberOfSections(in tableView: UITableView) -> Int {
		if(data == nil){
			return 0
		}
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(data != nil){
			return 4
		}
		return 0
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 280
		}
		return 180
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		switch (indexPath as NSIndexPath).row {
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
			let vc: BehaviorViewController = BehaviorViewController()
			vc.data = self.data
			vc.title = "DAILY BEHAVIOR"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 3:
			let vc: PledgeViewController = PledgeViewController()
//			vc.title = "DAILY PRAYER"
			vc.data = self.data
			vc.title = "DAILY " + Character.shared.pledgeTypeName.uppercased()
			self.navigationController?.pushViewController(vc, animated: true)
			break
		default:
			break
		}
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch (indexPath as NSIndexPath).row {
		case 0:
			return lessonCellWithData(data)
		case 1:
			return quoteCellWithData(data)
		case 2:
			return behaviorCellWithData(data)
//			return challengesCellWithData(data)
		case 3:
			return pledgeCellWithData(data)
		default:
			return UITableViewCell()
		}
    }
	
	func lessonCellWithData(_ data:Lesson?) -> LessonTableViewCell {
		let cell = LessonTableViewCell()
		cell.title = data?.title?.uppercased()
//		print("needing image")
		if let imageFilename = data?.image{
			print(imageFilename)
			Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, didRequireDownload) in
//				print("cache return")
				cell.imageView?.image = image
				if(didRequireDownload){
					self.tableView.reloadData()
				}
			})
			// QUICK FIX for JPG / JPEG file name differences
			let filename: NSString = imageFilename as NSString
			let pathPrefix = filename.deletingPathExtension
			let alternateFileName = pathPrefix + ".jpeg"
			Cache.shared.imageFromStorageBucket(alternateFileName, completionHandler: { (image, didRequireDownload) in
//				print("cache return")
				cell.imageView?.image = image
				if(didRequireDownload){
					self.tableView.reloadData()
				}
			})

		}
		return cell
	}
	
	func quoteCellWithData(_ data:Lesson?) -> QuoteTableViewCell {
		let cell = QuoteTableViewCell()
		if let quoteText = data?.quote{
			cell.textLabel?.text = quoteText
		}
		return cell
	}

	func challengesCellWithData(_ data:Lesson?) -> ChallengesTableViewCell {
		let cell = ChallengesTableViewCell()
		cell.numberCompleted = numChallengesCompleted
		return cell
	}
	
	func behaviorCellWithData(_ data:Lesson?) -> BehaviorTableViewCell {
		let cell = BehaviorTableViewCell()
//		cell.numberCompleted = numChallengesCompleted
		return cell
	}

	func pledgeCellWithData(_ data:Lesson?) -> PledgeTableViewCell {
		let cell = PledgeTableViewCell()
		return cell
	}

}

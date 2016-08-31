//
//  SetupProfileViewController.swift
//  Character
//
//  Created by Robby on 8/25/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class SetupProfileViewController: UIViewController {
	
	let welcomeLabel = UILabel()
	let questionLabel = UILabel()
	let detailLabel = UILabel()
	
	let detail1Button: UIButton = UIButton()

	let detail2Button: UIButton = UIButton()

	let continueButton: UIButton = UIButton()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		questionLabel.numberOfLines = 0
		detailLabel.numberOfLines = 0
		welcomeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P40)
		questionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		detailLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		welcomeLabel.text = "Welcome!"
		questionLabel.text = "What grade do you teach?"
		detailLabel.text = "These can be changed under \"My Profile\""
		
		// buttons
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		detail2Button.addTarget(self, action: #selector(detail2ButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		continueButton.addTarget(self, action: #selector(continueButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		
		// ui custom
		detail1Button.backgroundColor = UIColor.whiteColor()
		detail1Button.setTitleColor(UIColor.blackColor(), forState: .Normal)
		detail1Button.titleLabel?.textAlignment = .Center
		detail2Button.backgroundColor = UIColor.whiteColor()
		detail2Button.setTitleColor(UIColor.blackColor(), forState: .Normal)
		detail2Button.titleLabel?.textAlignment = .Center
		continueButton.backgroundColor = Style.shared.lightBlue
		continueButton.setTitle("Continue", forState: .Normal)
		detail1Button.setTitle("All Grades", forState: .Normal)
		detail2Button.setTitle(Character.shared.SchoolNames[0], forState: .Normal)
		
		self.view.addSubview(welcomeLabel)
		self.view.addSubview(questionLabel)
		self.view.addSubview(detailLabel)
		self.view.addSubview(detail1Button)
		self.view.addSubview(detail2Button)
		self.view.addSubview(continueButton)
		
		Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3], completionHandler: nil)
		Fire.shared.updateUserWithKeyAndValue("school", value: 0, completionHandler: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// frames
		welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)
		questionLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)
		detail1Button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
		detail2Button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
		continueButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
		detailLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)

		welcomeLabel.sizeToFit()
		welcomeLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.25)

		questionLabel.sizeToFit()
		questionLabel.center = CGPointMake(self.view.center.x, self.view.center.y - questionLabel.frame.size.height - 40)

		detail1Button.center = self.view.center
		detail2Button.center = CGPointMake(self.view.center.x, self.view.center.y + 80)
		
		detailLabel.sizeToFit()
		detailLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height - detailLabel.frame.size.height - 20 - 22)

		continueButton.center = CGPointMake(self.view.center.x, detailLabel.center.y - continueButton.frame.size.height - 20)
	}
	
	
	func populateUserData(uid:String, userData:NSDictionary){
		var gradeLevels:[Int]? = userData["grade"] as? [Int]
		if(gradeLevels == nil){
			gradeLevels = [0,1,2,3]
		}
		if(gradeLevels!.contains(0) && gradeLevels!.contains(1) && gradeLevels!.contains(2) && gradeLevels!.contains(3)){
			detail1Button.setTitle("All Grades", forState: .Normal)
		}
		else if(gradeLevels!.contains(0)){
			detail1Button.setTitle(Character.shared.gradeNames[0], forState: .Normal)
		}
		else if(gradeLevels!.contains(1)){
			detail1Button.setTitle(Character.shared.gradeNames[1], forState: .Normal)
		}
		else if(gradeLevels!.contains(2)){
			detail1Button.setTitle(Character.shared.gradeNames[2], forState: .Normal)
		}
		else if(gradeLevels!.contains(3)){
			detail1Button.setTitle(Character.shared.gradeNames[3], forState: .Normal)
		}
	}
	
	func continueButtonHandler(){
		self.dismissViewControllerAnimated(true) {
			UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(MasterController(), animated: true, completion: nil)
		}
	}
	
	func detail1ButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .Default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[0], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0], completionHandler: nil)
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .Default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[1], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("grade", value: [1], completionHandler: nil)
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .Default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[2], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("grade", value: [2], completionHandler: nil)
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .Default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[3], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("grade", value: [3], completionHandler: nil)
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .Default) { (action) in
			self.detail1Button.setTitle("All Grades", forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3], completionHandler: nil)
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
	
//	func detail2ButtonHandler(sender:UIButton){
//		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
//		var index = 0
//		for schoolname in Character.shared.SchoolNames{
//			let action = UIAlertAction.init(title: schoolname, style: .Default) { (action) in
//				self.detail2Button.setTitle(schoolname, forState: .Normal)
//				let thisIndex = Int(index)
//				Fire.shared.updateUserWithKeyAndValue("school", value: thisIndex, completionHandler: nil)
//			}
//			alert.addAction(action)
//			index += 1
//		}
//		let cancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
//		alert.addAction(cancel)
//		self.presentViewController(alert, animated: true, completion: nil)
//	}
	func detail2ButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)

		let action0 = UIAlertAction.init(title: Character.shared.SchoolNames[0], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[0], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 0, completionHandler: nil)
		}
		alert.addAction(action0)

		let action1 = UIAlertAction.init(title: Character.shared.SchoolNames[1], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[1], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 1, completionHandler: nil)
		}
		alert.addAction(action1)

		let action2 = UIAlertAction.init(title: Character.shared.SchoolNames[2], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[2], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 2, completionHandler: nil)
		}
		alert.addAction(action2)

		let action3 = UIAlertAction.init(title: Character.shared.SchoolNames[3], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[3], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 3, completionHandler: nil)
		}
		alert.addAction(action3)

		let action4 = UIAlertAction.init(title: Character.shared.SchoolNames[4], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[4], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 4, completionHandler: nil)
		}
		alert.addAction(action4)

		let action5 = UIAlertAction.init(title: Character.shared.SchoolNames[5], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[5], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 5, completionHandler: nil)
		}
		alert.addAction(action5)
		
		let action6 = UIAlertAction.init(title: Character.shared.SchoolNames[6], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[6], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 6, completionHandler: nil)
		}
		alert.addAction(action6)
		
		let action7 = UIAlertAction.init(title: Character.shared.SchoolNames[7], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[7], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 7, completionHandler: nil)
		}
		alert.addAction(action7)

		let action8 = UIAlertAction.init(title: Character.shared.SchoolNames[8], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[8], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 8, completionHandler: nil)
		}
		alert.addAction(action8)

		let action9 = UIAlertAction.init(title: Character.shared.SchoolNames[9], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[9], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 9, completionHandler: nil)
		}
		alert.addAction(action9)

		let action10 = UIAlertAction.init(title: Character.shared.SchoolNames[10], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[10], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 10, completionHandler: nil)
		}
		alert.addAction(action10)

		let action11 = UIAlertAction.init(title: Character.shared.SchoolNames[11], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[11], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 11, completionHandler: nil)
		}
		alert.addAction(action11)

		let action12 = UIAlertAction.init(title: Character.shared.SchoolNames[12], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[12], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 12, completionHandler: nil)
		}
		alert.addAction(action12)

		let action13 = UIAlertAction.init(title: Character.shared.SchoolNames[13], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[13], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 13, completionHandler: nil)
		}
		alert.addAction(action13)

		let action14 = UIAlertAction.init(title: Character.shared.SchoolNames[14], style: .Default) { (action) in
			self.detail2Button.setTitle(Character.shared.SchoolNames[14], forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("school", value: 14, completionHandler: nil)
		}
		alert.addAction(action14)

		let cancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
		alert.addAction(cancel)

		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.presentViewController(alert, animated: true, completion: nil)
	}

}

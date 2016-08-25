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

	let continueButton: UIButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		questionLabel.numberOfLines = 0
		detailLabel.numberOfLines = 0
		welcomeLabel.font = UIFont(name: SYSTEM_FONT, size: 40)
		questionLabel.font = UIFont(name: SYSTEM_FONT, size: 23)
		detailLabel.font = UIFont(name: SYSTEM_FONT, size: 14)
		welcomeLabel.text = "Welcome!"
		questionLabel.text = "What grade do you teach?"
		detailLabel.text = "This can be changed under \"My Profile\""
		
		// buttons
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		continueButton.addTarget(self, action: #selector(continueButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		
		// ui custom
		detail1Button.backgroundColor = UIColor.whiteColor()
		detail1Button.setTitleColor(UIColor.blackColor(), forState: .Normal)
		detail1Button.titleLabel?.textAlignment = .Center
		continueButton.backgroundColor = Style.shared.lightBlue
		continueButton.setTitle("Continue", forState: .Normal)
		detail1Button.setTitle("All Grades", forState: .Normal)
		
		self.view.addSubview(welcomeLabel)
		self.view.addSubview(questionLabel)
		self.view.addSubview(detailLabel)
		self.view.addSubview(detail1Button)
		self.view.addSubview(continueButton)
		
		Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3], completionHandler: nil)
	}
	
	override func viewWillAppear(animated: Bool) {

		// frames
		welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)
		questionLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)
		detail1Button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
		continueButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
		detailLabel.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.8, self.view.frame.size.height)

		welcomeLabel.sizeToFit()
		welcomeLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.25)

		questionLabel.sizeToFit()
		questionLabel.center = CGPointMake(self.view.center.x, self.view.center.y - questionLabel.frame.size.height - 40)

		detail1Button.center = self.view.center
		
		detailLabel.sizeToFit()
		detailLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height - detailLabel.frame.size.height - 20)

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
		self.presentViewController(MasterController(), animated: true, completion: nil)
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
		self.presentViewController(alert, animated: true, completion: nil)
	}

}

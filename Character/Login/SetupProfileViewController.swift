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
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), for: UIControlEvents.touchUpInside)
		detail2Button.addTarget(self, action: #selector(detail2ButtonHandler), for: UIControlEvents.touchUpInside)
		continueButton.addTarget(self, action: #selector(continueButtonHandler), for: UIControlEvents.touchUpInside)
		
		// ui custom
		detail1Button.backgroundColor = UIColor.white
		detail1Button.setTitleColor(UIColor.black, for: UIControlState())
		detail1Button.titleLabel?.textAlignment = .center
		detail2Button.backgroundColor = UIColor.white
		detail2Button.setTitleColor(UIColor.black, for: UIControlState())
		detail2Button.titleLabel?.textAlignment = .center
		continueButton.backgroundColor = Style.shared.lightBlue
		continueButton.setTitle("Continue", for: UIControlState())
		detail1Button.setTitle("All Grades", for: UIControlState())
//		detail2Button.setTitle(Character.shared.SchoolNames[0], for: UIControlState())
		
		self.view.addSubview(welcomeLabel)
		self.view.addSubview(questionLabel)
		self.view.addSubview(detailLabel)
		self.view.addSubview(detail1Button)
		self.view.addSubview(detail2Button)
		self.view.addSubview(continueButton)
		
		Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3] as AnyObject, completionHandler: nil)
		Fire.shared.updateUserWithKeyAndValue("school", value: 0 as AnyObject, completionHandler: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// frames
		welcomeLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height)
		questionLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height)
		detail1Button.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		detail2Button.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		continueButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		detailLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height)

		welcomeLabel.sizeToFit()
		welcomeLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height * 0.25)

		questionLabel.sizeToFit()
		questionLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y - questionLabel.frame.size.height - 40)

		detail1Button.center = self.view.center
		detail2Button.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 80)
		
		detailLabel.sizeToFit()
		detailLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - detailLabel.frame.size.height - 20 - 22)

		continueButton.center = CGPoint(x: self.view.center.x, y: detailLabel.center.y - continueButton.frame.size.height - 20)
	}
	
	
	func populateUserData(_ uid:String, userData:NSDictionary){
		var gradeLevels:[Int]? = userData["grade"] as? [Int]
		if(gradeLevels == nil){
			gradeLevels = [0,1,2,3]
		}
		if(gradeLevels!.contains(0) && gradeLevels!.contains(1) && gradeLevels!.contains(2) && gradeLevels!.contains(3)){
			detail1Button.setTitle("All Grades", for: UIControlState())
		}
		else if(gradeLevels!.contains(0)){
			detail1Button.setTitle(Character.shared.gradeNames[0], for: UIControlState())
		}
		else if(gradeLevels!.contains(1)){
			detail1Button.setTitle(Character.shared.gradeNames[1], for: UIControlState())
		}
		else if(gradeLevels!.contains(2)){
			detail1Button.setTitle(Character.shared.gradeNames[2], for: UIControlState())
		}
		else if(gradeLevels!.contains(3)){
			detail1Button.setTitle(Character.shared.gradeNames[3], for: UIControlState())
		}
	}
	
	func continueButtonHandler(){
		self.dismiss(animated: true) {
			UIApplication.shared.keyWindow?.rootViewController?.present(MasterController(), animated: true, completion: nil)
		}
	}
	
	func detail1ButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[0], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0] as AnyObject, completionHandler: nil)
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[1], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [1] as AnyObject, completionHandler: nil)
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[2], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [2] as AnyObject, completionHandler: nil)
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[3], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [3] as AnyObject, completionHandler: nil)
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .default) { (action) in
			self.detail1Button.setTitle("All Grades", for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3] as AnyObject, completionHandler: nil)
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
	func detail2ButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)

//		let action0 = UIAlertAction.init(title: Character.shared.SchoolNames[0], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[0], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 0 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action0)
//
//		let action1 = UIAlertAction.init(title: Character.shared.SchoolNames[1], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[1], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 1 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action1)
//
//		let action2 = UIAlertAction.init(title: Character.shared.SchoolNames[2], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[2], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 2 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action2)
//
//		let action3 = UIAlertAction.init(title: Character.shared.SchoolNames[3], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[3], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 3 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action3)
//
//		let action4 = UIAlertAction.init(title: Character.shared.SchoolNames[4], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[4], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 4 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action4)
//
//		let action5 = UIAlertAction.init(title: Character.shared.SchoolNames[5], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[5], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 5 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action5)
//		
//		let action6 = UIAlertAction.init(title: Character.shared.SchoolNames[6], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[6], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 6 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action6)
//		
//		let action7 = UIAlertAction.init(title: Character.shared.SchoolNames[7], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[7], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 7 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action7)
//
//		let action8 = UIAlertAction.init(title: Character.shared.SchoolNames[8], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[8], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 8 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action8)
//
//		let action9 = UIAlertAction.init(title: Character.shared.SchoolNames[9], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[9], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 9 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action9)
//
//		let action10 = UIAlertAction.init(title: Character.shared.SchoolNames[10], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[10], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 10 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action10)
//
//		let action11 = UIAlertAction.init(title: Character.shared.SchoolNames[11], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[11], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 11 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action11)
//
//		let action12 = UIAlertAction.init(title: Character.shared.SchoolNames[12], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[12], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 12 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action12)
//
//		let action13 = UIAlertAction.init(title: Character.shared.SchoolNames[13], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[13], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 13 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action13)
//
//		let action14 = UIAlertAction.init(title: Character.shared.SchoolNames[14], style: .default) { (action) in
//			self.detail2Button.setTitle(Character.shared.SchoolNames[14], for: UIControlState())
//			Fire.shared.updateUserWithKeyAndValue("school", value: 14 as AnyObject, completionHandler: nil)
//		}
//		alert.addAction(action14)

		let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
		alert.addAction(cancel)

		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.present(alert, animated: true, completion: nil)
	}

}

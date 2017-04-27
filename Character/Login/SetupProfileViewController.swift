//
//  SetupProfileViewController.swift
//  Character
//
//  Created by Robby on 8/25/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class SetupProfileViewController: UIViewController, UITextFieldDelegate {
	
	let imageView = UIImageView()
	
	let welcomeLabel = UILabel()
	let question1Label = UILabel()
	let question2Label = UILabel()
	let detailLabel = UILabel()
	
	let detail1Button: UIButton = UIButton()
	let detail2Field: UITextField = UITextField()

	let continueButton: UIButton = UIButton()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		question1Label.numberOfLines = 0
		question2Label.numberOfLines = 0
		detailLabel.numberOfLines = 0
		welcomeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P40)
		question1Label.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		question2Label.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		detailLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		welcomeLabel.text = "Welcome!"
		question1Label.text = "What grade do you teach?"
		question2Label.text = "If you have a password, enter it here:"
		detailLabel.text = "These can be changed under \"My Profile\""
		
		imageView.image = UIImage(named: "icon")
		imageView.alpha = 0.3
		self.view.addSubview(imageView)
		
		// input
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), for: UIControlEvents.touchUpInside)
		detail2Field.placeholder = "optional"
		detail2Field.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		continueButton.addTarget(self, action: #selector(continueButtonHandler), for: UIControlEvents.touchUpInside)
		
		// ui custom
		detail1Button.backgroundColor = UIColor.white
		detail1Button.setTitleColor(UIColor.black, for: UIControlState())
		detail1Button.titleLabel?.textAlignment = .center
		detail2Field.backgroundColor = UIColor.white
		detail2Field.textColor = UIColor.black
		detail2Field.textAlignment = .center
		continueButton.backgroundColor = Style.shared.lightBlue
		continueButton.setTitle("Continue", for: UIControlState())
		detail1Button.setTitle("All Grades", for: UIControlState())
		detail2Field.delegate = self
		
		self.view.addSubview(welcomeLabel)
		self.view.addSubview(question1Label)
		self.view.addSubview(question2Label)
		self.view.addSubview(detailLabel)
		self.view.addSubview(detail1Button)
		self.view.addSubview(detail2Field)
		self.view.addSubview(continueButton)
		
//		Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3] as AnyObject, completionHandler: nil)
//		Fire.shared.updateUserWithKeyAndValue("school", value: 0 as AnyObject, completionHandler: nil)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.5, height: self.view.frame.size.width*0.5)
		imageView.center = CGPoint(x: self.view.frame.size.width*0.5, y: self.view.frame.size.width*0.3)

		// frames
		welcomeLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height)
		question1Label.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.9, height: self.view.frame.size.height)
		question2Label.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.9, height: self.view.frame.size.height)
		detail1Button.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		detail2Field.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		continueButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		detailLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height)

		welcomeLabel.sizeToFit()
		welcomeLabel.center = CGPoint(x: self.view.center.x, y: imageView.center.y + imageView.frame.size.height*0.5)

		question1Label.sizeToFit()
		question1Label.center = CGPoint(x: self.view.center.x, y: welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height*0.5 + question1Label.frame.size.height*0.5 + 30)

		detail1Button.center = CGPoint(x: self.view.center.x, y: question1Label.center.y  + question1Label.frame.size.height*0.5 + 30)
		
		
		question2Label.sizeToFit()
		question2Label.center = CGPoint(x: self.view.center.x, y: detail1Button.frame.origin.y + 44 + 10 + 44 + question2Label.frame.size.height*0.5)

		detail2Field.center = CGPoint(x: self.view.center.x, y: question2Label.frame.origin.y + question2Label.frame.size.height + 10 + 22)
		

		detailLabel.sizeToFit()
		detailLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - detailLabel.frame.size.height*0.5 - 20 )

		continueButton.center = CGPoint(x: self.view.center.x, y: detailLabel.center.y - detailLabel.frame.size.height*0.5 - continueButton.frame.size.height*0.5 - 15)
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
		if let paidPassword:String = detail2Field.text{
			if(!paidPassword.isEmpty){
				Fire.shared.loadData("clients", completionHandler: { (data) in
					var didMatchClient:String?
					var matchedClientNameString = ""
					if let clientList:[String:Any] = data as? [String:Any]{
						let keys = Array(clientList.keys)
						for k in keys{
							if let thisClient = clientList[k] as? [String:Any]{
								if let clientPassword:String = thisClient["password"] as? String{
									if clientPassword == paidPassword{
										didMatchClient = k
										matchedClientNameString = thisClient["name"] as! String
									}
								}
							}
						}
					}
					if let clientMatch:String = didMatchClient{
						Fire.shared.updateUserWithKeyAndValue("client", value: clientMatch as AnyObject, completionHandler: { (success) in
							
							let alert = UIAlertController.init(title: "Welcome!", message: "You are now a member of " + matchedClientNameString, preferredStyle: .alert)
							let dismiss = UIAlertAction.init(title: "Continue", style: .default, handler: { (action) in
								self.proceed()
							})
							alert.addAction(dismiss)
							self.present(alert, animated: true, completion: nil)
						})
					}
				})
			} else{
				proceed()
			}
		} else{
			proceed()
		}
	}
	
	func proceed(){
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
	
}

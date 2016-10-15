//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
	
	let button1:UIButton = UIButton()
	let button2:UIButton = UIButton()
	let button3:UIButton = UIButton()
	let button4:UIButton = UIButton()
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()

//		preferredStatusBarStyle
		
		self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);

		self.view.backgroundColor = Style.shared.whiteSmoke
		
		
		let imgSize:CGFloat = 75
		profileImageView.frame = CGRect(x: 0, y: 0, width: imgSize, height: imgSize)
		profileImageView.layer.cornerRadius = imgSize*0.5
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.backgroundColor = UIColor.white
		profileImageView.clipsToBounds = true
		self.view.addSubview(profileImageView)

		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "MORE CHARACTER TOOLS")
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "MY CHARACTER SCORE")
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "PROVIDE APP FEEDBACK")
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: "MY PROFILE")
		
		aTitle1.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle4.length))

		button2.titleLabel?.numberOfLines = 2

		button1.setAttributedTitle(aTitle1, for: UIControlState())
		button2.setAttributedTitle(aTitle2, for: UIControlState())
		button3.setAttributedTitle(aTitle3, for: UIControlState())
		button4.setAttributedTitle(aTitle4, for: UIControlState())
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		button4.sizeToFit()
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
		self.view.addSubview(profileImageButton)

		button1.addTarget(self, action: #selector(characterToolsHandler), for:.touchUpInside)
		button2.addTarget(self, action: #selector(scoreButtonHandler), for:.touchUpInside)
		button3.addTarget(self, action: #selector(feedbackButtonHandler), for:.touchUpInside)
		button4.addTarget(self, action: #selector(profileButtonHandler), for:.touchUpInside)
		profileImageButton.addTarget(self, action: #selector(profileButtonHandler), for: .touchUpInside)

		

		getProfileImage()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let startY:CGFloat = 150
		var spacing:CGFloat = 50
		if(IS_IPAD){
			spacing = 100
		}

		button1.center = CGPoint(x: self.view.center.x, y: startY)
		button2.center = CGPoint(x: self.view.center.x, y: startY + spacing)
		button3.center = CGPoint(x: self.view.center.x, y: startY + spacing*2)
		
		let bottomPad:CGFloat = self.view.bounds.size.width * 0.1
		button4.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - bottomPad - button4.frame.size.height*0.5)
		profileImageView.center = CGPoint(x: self.view.center.x, y: button4.center.y - button4.frame.size.height*0.5 - profileImageView.frame.size.height * 0.5 - 10)
		profileImageButton.frame = profileImageView.frame
		
	}
	
	func getProfileImage() {
		Fire.shared.getUser { (uid, userData) in
			if(uid != nil && userData != nil){
				if(userData!["image"] != nil){
					self.profileImageView.profileImageFromUID(uid!)
				}
				else{
					self.profileImageView.image = UIImage(named: "person")?.imageWithTint(Style.shared.lightBlue)
				}
			}
		}
	}
	
	func characterToolsHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(CharacterToolsViewController(), animated: true)
	}
	func feedbackButtonHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(FeedbackViewController(), animated: true)
	}
	func scoreButtonHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(ScoreViewController(), animated: true)
	}
	func profileButtonHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(ProfileViewController(), animated: true)
	}

}

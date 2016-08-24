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
	let button5:UIButton = UIButton()

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		preferredStatusBarStyle()
		
		self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent

		self.view.backgroundColor = Style.shared.darkGray
		
		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSForegroundColorAttributeName : UIColor.whiteColor()];
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .Center
		let attributes2 = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSParagraphStyleAttributeName: titleParagraphStyle,
		                  NSForegroundColorAttributeName : UIColor.whiteColor()];

		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "THE SIX PILLARS")
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "catholic faith\nintegration".uppercaseString)
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "MY CHARACTER SCORE")
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: "PROVIDE APP FEEDBACK")
		let aTitle5:NSMutableAttributedString = NSMutableAttributedString(string: "MANAGE PROFILE")
		
		aTitle1.addAttributes(attributes, range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(attributes2, range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(attributes, range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(attributes, range: NSMakeRange(0, aTitle4.length))
		aTitle5.addAttributes(attributes, range: NSMakeRange(0, aTitle5.length))

		button2.titleLabel?.numberOfLines = 2

		button1.setAttributedTitle(aTitle1, forState: .Normal)
		button2.setAttributedTitle(aTitle2, forState: .Normal)
		button3.setAttributedTitle(aTitle3, forState: .Normal)
		button4.setAttributedTitle(aTitle4, forState: .Normal)
		button5.setAttributedTitle(aTitle5, forState: .Normal)
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		button4.sizeToFit()
		button5.sizeToFit()
		
		button3.alpha = 0.5
		button4.alpha = 0.5

		button1.center = CGPointMake(self.view.center.x, 100 - 30)
		button2.center = CGPointMake(self.view.center.x, 150 - 15)
		button3.center = CGPointMake(self.view.center.x, 200)
		button4.center = CGPointMake(self.view.center.x, 250)
		button5.center = CGPointMake(self.view.center.x, 300)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
		self.view.addSubview(button5)
		
		button1.addTarget(self, action: #selector(sixPillarsHandler), forControlEvents:.TouchUpInside)
		button2.addTarget(self, action: #selector(catholicHandler), forControlEvents:.TouchUpInside)
		button5.addTarget(self, action: #selector(profileButtonHandler), forControlEvents:.TouchUpInside)

	}
	
	func sixPillarsHandler(sender:UIButton){
		self.navigationController?.pushViewController(SixPillarsViewController(), animated: true)
	}
	func catholicHandler(sender:UIButton){
		self.navigationController?.pushViewController(CatholicViewController(), animated: true)
	}
	func profileButtonHandler(sender:UIButton){
		self.navigationController?.pushViewController(ProfileViewController(), animated: true)
	}

}

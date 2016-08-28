//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class CatholicViewController: UIViewController {
	
	let button1:UIButton = UIButton()
	let button2:UIButton = UIButton()
	let button3:UIButton = UIButton()
	
	let titleLabel:UILabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);		
		
		let attribTitle = [NSFontAttributeName : UIFont(name: SYSTEM_FONT_I, size: 22)!,
		                   NSKernAttributeName : CGFloat(2.4),
		                   NSForegroundColorAttributeName : Style.shared.gray];
		let titleText:NSMutableAttributedString = NSMutableAttributedString(string: "The Six Pillars and".uppercaseString)
		titleText.addAttributes(attribTitle, range: NSMakeRange(0, titleText.length))
		titleLabel.attributedText = titleText
		titleLabel.sizeToFit()
		titleLabel.center = CGPointMake(self.view.center.x, 150)
		self.view.addSubview(titleLabel)

		
		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSForegroundColorAttributeName : Style.shared.darkGray];
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "Liturgical Calendar".uppercaseString)
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "Our Blessed Mother".uppercaseString)
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "Works of Mercy".uppercaseString)
		
		aTitle1.addAttributes(attributes, range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(attributes, range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(attributes, range: NSMakeRange(0, aTitle3.length))

		button1.setAttributedTitle(aTitle1, forState: .Normal)
		button2.setAttributedTitle(aTitle2, forState: .Normal)
		button3.setAttributedTitle(aTitle3, forState: .Normal)
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		
		button1.center = CGPointMake(self.view.center.x, 200)
		button2.center = CGPointMake(self.view.center.x, 250)
		button3.center = CGPointMake(self.view.center.x, 300)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		
		button1.addTarget(self, action: #selector(liturgicalHandler), forControlEvents:.TouchUpInside)
		button2.addTarget(self, action: #selector(motherHandler), forControlEvents:.TouchUpInside)
		button3.addTarget(self, action: #selector(mercyHandler), forControlEvents:.TouchUpInside)
		
	}
	
	func liturgicalHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/liturgical"
		vc.title = "LITURGICAL CALENDAR"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func motherHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/mother"
		vc.title = "OUR BLESSED MOTHER"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func mercyHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/mercy"
		vc.title = "WORKS OF MERCY"
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

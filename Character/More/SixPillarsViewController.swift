//
//  MoreViewController.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class SixPillarsViewController: UIViewController {
	
	let button1:UIButton = UIButton()
	let button2:UIButton = UIButton()
	let button3:UIButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.darkGray
		
		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSForegroundColorAttributeName : UIColor.whiteColor()];
		
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
		
		button1.center = CGPointMake(self.view.center.x, 100)
		button2.center = CGPointMake(self.view.center.x, 150)
		button3.center = CGPointMake(self.view.center.x, 200)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		
		button1.addTarget(self, action: #selector(liturgicalHandler), forControlEvents:.TouchUpInside)
		button2.addTarget(self, action: #selector(motherHandler), forControlEvents:.TouchUpInside)
		button3.addTarget(self, action: #selector(mercyHandler), forControlEvents:.TouchUpInside)
		
	}
	
	func liturgicalHandler(sender:UIButton){
		self.navigationController?.pushViewController(LiturgicalViewController(), animated: true)
	}
	func motherHandler(sender:UIButton){
		self.navigationController?.pushViewController(MotherViewController(), animated: true)
	}
	func mercyHandler(sender:UIButton){
		self.navigationController?.pushViewController(MercyViewController(), animated: true)
	}

}

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
	let button4:UIButton = UIButton()
	let button5:UIButton = UIButton()
	let button6:UIButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.darkGray
		
		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSForegroundColorAttributeName : UIColor.whiteColor()];
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[0].uppercaseString)
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[1].uppercaseString)
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[2].uppercaseString)
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[3].uppercaseString)
		let aTitle5:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[4].uppercaseString)
		let aTitle6:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[5].uppercaseString)
		
		aTitle1.addAttributes(attributes, range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(attributes, range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(attributes, range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(attributes, range: NSMakeRange(0, aTitle4.length))
		aTitle5.addAttributes(attributes, range: NSMakeRange(0, aTitle5.length))
		aTitle6.addAttributes(attributes, range: NSMakeRange(0, aTitle6.length))

		button1.setAttributedTitle(aTitle1, forState: .Normal)
		button2.setAttributedTitle(aTitle2, forState: .Normal)
		button3.setAttributedTitle(aTitle3, forState: .Normal)
		button4.setAttributedTitle(aTitle4, forState: .Normal)
		button5.setAttributedTitle(aTitle5, forState: .Normal)
		button6.setAttributedTitle(aTitle6, forState: .Normal)
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		button4.sizeToFit()
		button5.sizeToFit()
		button6.sizeToFit()
		
		button1.tag = 0
		button2.tag = 1
		button3.tag = 2
		button4.tag = 3
		button5.tag = 4
		button6.tag = 5
		
		button1.center = CGPointMake(self.view.center.x, 100)
		button2.center = CGPointMake(self.view.center.x, 150)
		button3.center = CGPointMake(self.view.center.x, 200)
		button4.center = CGPointMake(self.view.center.x, 250)
		button5.center = CGPointMake(self.view.center.x, 300)
		button6.center = CGPointMake(self.view.center.x, 350)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
		self.view.addSubview(button5)
		self.view.addSubview(button6)
		
		button1.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		button2.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		button3.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		button4.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		button5.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		button6.addTarget(self, action: #selector(buttonHandler), forControlEvents:.TouchUpInside)
		
	}
	
	func buttonHandler(sender:UIButton){
		print(sender.tag)
		let vc = PillarViewController()
		vc.pillarNumber = sender.tag
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

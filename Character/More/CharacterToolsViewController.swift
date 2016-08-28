//
//  CharacterToolsViewController.swift
//  Character
//
//  Created by Robby on 8/28/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class CharacterToolsViewController: UIViewController {
	
	let button1:UIButton = UIButton()
	let button2:UIButton = UIButton()
	let button3:UIButton = UIButton()
	let button4:UIButton = UIButton()
	let button5:UIButton = UIButton()
	let button6:UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "CHARACTER TOOLS"
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .Center

		let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                  NSKernAttributeName : CGFloat(2.4),
		                  NSParagraphStyleAttributeName: titleParagraphStyle,
		                  NSForegroundColorAttributeName : Style.shared.darkGray];
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "THE SIX PILLARS")
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "CATHOLIC FAITH\nINTEGRATION")
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "LOCKS AND KEYS")
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: "T.E.A.M")
		let aTitle5:NSMutableAttributedString = NSMutableAttributedString(string: "DECISION MAKING")
		let aTitle6:NSMutableAttributedString = NSMutableAttributedString(string: "COMMITMENT TO\nCHARACTER AND ETHICS")
		
		aTitle1.addAttributes(attributes, range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(attributes, range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(attributes, range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(attributes, range: NSMakeRange(0, aTitle4.length))
		aTitle5.addAttributes(attributes, range: NSMakeRange(0, aTitle5.length))
		aTitle6.addAttributes(attributes, range: NSMakeRange(0, aTitle6.length))
		
		button1.titleLabel?.numberOfLines = 0
		button2.titleLabel?.numberOfLines = 0
		button3.titleLabel?.numberOfLines = 0
		button4.titleLabel?.numberOfLines = 0
		button5.titleLabel?.numberOfLines = 0
		button6.titleLabel?.numberOfLines = 0
		
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
		
		button1.center = CGPointMake(self.view.center.x, 100 - 44)
		button2.center = CGPointMake(self.view.center.x, 150 - 22)
		button3.center = CGPointMake(self.view.center.x, 200)
		button4.center = CGPointMake(self.view.center.x, 250)
		button5.center = CGPointMake(self.view.center.x, 300)
		button6.center = CGPointMake(self.view.center.x, 350 + 22)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
		self.view.addSubview(button5)
		self.view.addSubview(button6)
		
		button1.addTarget(self, action: #selector(sixPillarsHandler), forControlEvents:.TouchUpInside)
		button2.addTarget(self, action: #selector(catholicHandler), forControlEvents:.TouchUpInside)
		button3.addTarget(self, action: #selector(lockHandler), forControlEvents:.TouchUpInside)
		button4.addTarget(self, action: #selector(teamHandler), forControlEvents:.TouchUpInside)
		button5.addTarget(self, action: #selector(decisionHandler), forControlEvents:.TouchUpInside)
		button6.addTarget(self, action: #selector(commitmentHandler), forControlEvents:.TouchUpInside)
    }
	
	func sixPillarsHandler(sender:UIButton){
		self.navigationController?.pushViewController(SixPillarsViewController(), animated: true)
	}
	func catholicHandler(sender:UIButton){
		self.navigationController?.pushViewController(CatholicViewController(), animated: true)
	}
	func lockHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/locksandkeys"
		vc.title = "LOCKS AND KEYS"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func teamHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/team"
		vc.title = "T.E.A.M"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func decisionHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/decision"
		vc.title = "DECISION MAKING"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func commitmentHandler(sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/commitment"
//		vc.title = ""
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

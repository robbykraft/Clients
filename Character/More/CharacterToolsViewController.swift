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
//	let button5:UIButton = UIButton()
//	let button6:UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "CHARACTER TOOLS"
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "THE SIX PILLARS")
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "CATHOLIC FAITH\nINTEGRATION")
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "LOCKS AND KEYS")
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: "T.E.A.M")
//		let aTitle5:NSMutableAttributedString = NSMutableAttributedString(string: "DECISION MAKING")
//		let aTitle6:NSMutableAttributedString = NSMutableAttributedString(string: "COMMITMENT TO\nCHARACTER AND ETHICS")
		
		aTitle1.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle4.length))
//		aTitle5.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle5.length))
//		aTitle6.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle6.length))
		
		button1.titleLabel?.numberOfLines = 0
		button2.titleLabel?.numberOfLines = 0
		button3.titleLabel?.numberOfLines = 0
		button4.titleLabel?.numberOfLines = 0
//		button5.titleLabel?.numberOfLines = 0
//		button6.titleLabel?.numberOfLines = 0
		
		button1.setAttributedTitle(aTitle1, for: UIControlState())
		button2.setAttributedTitle(aTitle2, for: UIControlState())
		button3.setAttributedTitle(aTitle3, for: UIControlState())
		button4.setAttributedTitle(aTitle4, for: UIControlState())
//		button5.setAttributedTitle(aTitle5, forState: .Normal)
//		button6.setAttributedTitle(aTitle6, forState: .Normal)
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		button4.sizeToFit()
//		button5.sizeToFit()
//		button6.sizeToFit()
		
		var startY:CGFloat = 150
		var spacing:CGFloat = 50
		var adjust:CGFloat = 22
		if(IS_IPAD){
			startY = 300
			spacing = 100
			adjust = 44
		}
		
		button1.center = CGPoint(x: self.view.center.x, y: startY - adjust*2)
		button2.center = CGPoint(x: self.view.center.x, y: startY + spacing - adjust)
		button3.center = CGPoint(x: self.view.center.x, y: startY + spacing*2 )
		button4.center = CGPoint(x: self.view.center.x, y: startY + spacing*3 )
//		button5.center = CGPointMake(self.view.center.x, 350)
//		button6.center = CGPointMake(self.view.center.x, 350 + adjust)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
//		self.view.addSubview(button5)
//		self.view.addSubview(button6)
		
		button1.addTarget(self, action: #selector(sixPillarsHandler), for:.touchUpInside)
		button2.addTarget(self, action: #selector(catholicHandler), for:.touchUpInside)
		button3.addTarget(self, action: #selector(lockHandler), for:.touchUpInside)
		button4.addTarget(self, action: #selector(teamHandler), for:.touchUpInside)
//		button5.addTarget(self, action: #selector(decisionHandler), forControlEvents:.TouchUpInside)
//		button6.addTarget(self, action: #selector(commitmentHandler), forControlEvents:.TouchUpInside)
    }
	
	func sixPillarsHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(SixPillarsViewController(), animated: true)
	}
	func catholicHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(CatholicViewController(), animated: true)
	}
	func lockHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/locksandkeys"
		vc.title = "LOCKS AND KEYS"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func teamHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/team"
		vc.title = "T.E.A.M"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func decisionHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/decision"
		vc.title = "DECISION MAKING"
		self.navigationController?.pushViewController(vc, animated: true)
	}
//	func commitmentHandler(sender:UIButton){
//		let vc = DatabasePageViewController()
//		vc.databasePath = "evergreen/integration/commitment"
////		vc.title = ""
//		self.navigationController?.pushViewController(vc, animated: true)
//	}
}

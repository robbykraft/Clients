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
		
		self.title = "THE SIX PILLARS"
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);

		self.view.backgroundColor = Style.shared.whiteSmoke
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[0].uppercased())
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[1].uppercased())
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[2].uppercased())
		let aTitle4:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[3].uppercased())
		let aTitle5:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[4].uppercased())
		let aTitle6:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.pillarNames[5].uppercased())
		
		aTitle1.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle3.length))
		aTitle4.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle4.length))
		aTitle5.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle5.length))
		aTitle6.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle6.length))

		button1.setAttributedTitle(aTitle1, for: UIControlState())
		button2.setAttributedTitle(aTitle2, for: UIControlState())
		button3.setAttributedTitle(aTitle3, for: UIControlState())
		button4.setAttributedTitle(aTitle4, for: UIControlState())
		button5.setAttributedTitle(aTitle5, for: UIControlState())
		button6.setAttributedTitle(aTitle6, for: UIControlState())
		
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
		
		
		var startY:CGFloat = 100
		var spacing:CGFloat = 50
		if(IS_IPAD){
			startY = 200
			spacing = 100
		}
		
		button1.center = CGPoint(x: self.view.center.x, y: startY)
		button2.center = CGPoint(x: self.view.center.x, y: startY + spacing)
		button3.center = CGPoint(x: self.view.center.x, y: startY + spacing*2)
		button4.center = CGPoint(x: self.view.center.x, y: startY + spacing*3)
		button5.center = CGPoint(x: self.view.center.x, y: startY + spacing*4)
		button6.center = CGPoint(x: self.view.center.x, y: startY + spacing*5)
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		self.view.addSubview(button4)
		self.view.addSubview(button5)
		self.view.addSubview(button6)
		
		button1.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		button2.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		button3.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		button4.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		button5.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		button6.addTarget(self, action: #selector(buttonHandler), for:.touchUpInside)
		
	}
	
	func buttonHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.title = Character.shared.pillarNames[sender.tag].uppercased()
		vc.databasePath = "evergreen/pillars/\(sender.tag)"
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

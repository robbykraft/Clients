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
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);		
		
		var attribTitle = Style.shared.heading1Attributes()
		attribTitle[NSForegroundColorAttributeName] = Style.shared.gray;
		
		let titleText:NSMutableAttributedString = NSMutableAttributedString(string: "The Six Pillars and".uppercased())
		titleText.addAttributes(attribTitle, range: NSMakeRange(0, titleText.length))
		titleLabel.attributedText = titleText
		titleLabel.sizeToFit()
		self.view.addSubview(titleLabel)

				
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "Liturgical Calendar".uppercased())
		let aTitle2:NSMutableAttributedString = NSMutableAttributedString(string: "Our Blessed Mother".uppercased())
		let aTitle3:NSMutableAttributedString = NSMutableAttributedString(string: "Works of Mercy".uppercased())
		
		aTitle1.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle1.length))
		aTitle2.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle2.length))
		aTitle3.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle3.length))

		button1.setAttributedTitle(aTitle1, for: UIControlState())
		button2.setAttributedTitle(aTitle2, for: UIControlState())
		button3.setAttributedTitle(aTitle3, for: UIControlState())
		
		button1.sizeToFit()
		button2.sizeToFit()
		button3.sizeToFit()
		
		
		
		self.view.addSubview(button1)
		self.view.addSubview(button2)
		self.view.addSubview(button3)
		
		button1.addTarget(self, action: #selector(liturgicalHandler), for:.touchUpInside)
		button2.addTarget(self, action: #selector(motherHandler), for:.touchUpInside)
		button3.addTarget(self, action: #selector(mercyHandler), for:.touchUpInside)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		let startY:CGFloat = 150
		var spacing:CGFloat = 50
		if(IS_IPAD){
			spacing = 100
		}
		
		titleLabel.center = CGPoint(x: self.view.center.x, y: startY)
	
		button1.center = CGPoint(x: self.view.center.x, y: startY + spacing)
		button2.center = CGPoint(x: self.view.center.x, y: startY + spacing*2)
		button3.center = CGPoint(x: self.view.center.x, y: startY + spacing*3)
		
	}
	
	func liturgicalHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/liturgical"
		vc.title = "LITURGICAL CALENDAR"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func motherHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/mother"
		vc.title = "OUR BLESSED MOTHER"
		self.navigationController?.pushViewController(vc, animated: true)
	}
	func mercyHandler(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = "evergreen/integration/mercy"
		vc.title = "WORKS OF MERCY"
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

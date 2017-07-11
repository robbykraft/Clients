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
	var buttons:[UIButton] = []
	var bodyTextURLs:[String] = [] // database urls from root, 1:1 for each of the buttons to load

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "CHARACTER TOOLS"
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		let aTitle1:NSMutableAttributedString = NSMutableAttributedString(string: "THE SIX PILLARS")
		aTitle1.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aTitle1.length))
		button1.titleLabel?.numberOfLines = 0
		button1.setAttributedTitle(aTitle1, for: UIControlState())
		button1.addTarget(self, action: #selector(sixPillarsHandler), for:.touchUpInside)
		
		self.view.addSubview(button1)
		
		self.loadFromDatabase()
    }
	
	func loadFromDatabase(){
		Fire.shared.loadData("evergreen/clients/default") { (data) in
			// load default evergreen content
			if let d = data as? [[String:String]]{
				for i in 0..<d.count{
					let item = d[i]
					let titleString:String = (item["title"] ?? "").uppercased()
					let button = UIButton()
					let attributed:NSMutableAttributedString = NSMutableAttributedString(string: titleString)
					attributed.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, attributed.length))
					button.titleLabel?.numberOfLines = 0
					button.setAttributedTitle(attributed, for: UIControlState())
					button.addTarget(self, action: #selector(self.dynamicButtonPressed), for: .touchUpInside)
					self.view.addSubview(button)
					button.tag = self.buttons.count
					self.buttons.append(button)
					self.bodyTextURLs.append("evergreen/clients/default/" + String(describing:i) + "/body")
				}
			}
			// load client data
			Fire.shared.getUser { (uid, data) in
				if let userData = data{
					if let userClient = userData["client"] as? String{
						if(userClient != "default"){
							Fire.shared.loadData("evergreen/clients/" + userClient) { (data) in
								if let d = data as? [[String:String]]{
									for i in 0..<d.count{
										let item = d[i]
										let titleString:String = (item["title"] ?? "").uppercased()
										let button = UIButton()
										let attributed:NSMutableAttributedString = NSMutableAttributedString(string: titleString)
										attributed.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, attributed.length))
										button.titleLabel?.numberOfLines = 0
										button.setAttributedTitle(attributed, for: UIControlState())
										button.addTarget(self, action: #selector(self.dynamicButtonPressed), for: .touchUpInside)
										self.view.addSubview(button)
										button.tag = self.buttons.count
										self.buttons.append(button)
										self.bodyTextURLs.append("evergreen/clients/" + userClient + "/" + String(describing:i) + "/body")
									}
								}
								self.layoutSubviews()
							}
						}
					}
				}
			}
			self.layoutSubviews()
		}
	}
	
	func layoutSubviews(){
		
		var startY:CGFloat = 100
		var spacing:CGFloat = 50
		if(IS_IPAD){
			startY = 200
			spacing = 100
		}
		
		button1.sizeToFit()
		for button in self.buttons{
			button.sizeToFit()
		}
		
		button1.center = CGPoint(x: self.view.center.x, y: startY )
		
		for i in 0..<self.buttons.count{
			let thisCenter = CGPoint(x: self.view.center.x, y: startY + spacing*CGFloat(i+1) )
			self.buttons[i].center = thisCenter
		}

	}
	func sixPillarsHandler(_ sender:UIButton){
		self.navigationController?.pushViewController(SixPillarsViewController(), animated: true)
	}
	func dynamicButtonPressed(_ sender:UIButton){
		let vc = DatabasePageViewController()
		vc.databasePath = self.bodyTextURLs[sender.tag]
		vc.title = sender.currentAttributedTitle?.string
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

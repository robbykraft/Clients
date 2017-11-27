//
//  DegreePanelView.swift
//  Allergy
//
//  Created by Robby on 11/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol DegreePanelDelegate{
	func didSelectDegree(sender:UIButton)
}

class DegreePanelView: UIView {
	
	var delegate:DegreePanelDelegate?
	
	let buttons = [UIButton(), UIButton(), UIButton(), UIButton()]
	
	convenience init() {
		self.init(frame:CGRect.zero)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}
	
	func initUI(){
		var i = 0
		let colors = [Style.shared.colorVeryHeavy, Style.shared.colorHeavy, Style.shared.colorMedium, Style.shared.colorNoPollen ]
		for button in buttons{
			self.addSubview(button)
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
			button.setTitleColor(colors[i], for: .normal)
			button.layer.borderColor = colors[i].cgColor
			button.layer.backgroundColor = UIColor.white.cgColor
			button.layer.cornerRadius = 20
			button.layer.borderWidth = 4
			button.addTarget(self, action: #selector(buttonDidPress(sender:)), for: .touchUpInside)
			i += 1
		}
		self.backgroundColor = UIColor(white:0.0, alpha:0.3)
	}
	
	@objc func buttonDidPress(sender:UIButton){
		if let d = self.delegate{
			d.didSelectDegree(sender: sender)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		var i:Int = 0
		let descriptions = ["severe", "medium", "light", "none"]
		let buttonH_Pad = self.bounds.size.height / 5.0
		
		for button in self.buttons{
			button.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width*0.75, height: self.bounds.size.height / 6.0)
			button.setTitle(descriptions[i], for: .normal)
			button.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5 - buttonH_Pad*1.5 + CGFloat(i)*buttonH_Pad)
			button.tag = 3-i
			i += 1
		}
	}

}

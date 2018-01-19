//
//  ButtonPanelView.swift
//  Allergy
//
//  Created by Robby on 11/15/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol SymptomPanelDelegate{
	func didSelectSymptom(index:Int)
}

class SymptomPanelView: UIView {
	
	var buttons:[UIButton] = Array(repeating:UIButton(), count:4)
	var symptomColors:[UIColor] = Array(repeating:Style.shared.colorNoEntry, count:4)
	var delegate:SymptomPanelDelegate?

	override func layoutSubviews() {
		super.layoutSubviews()
		let pad:CGFloat = 10
		let buttonRect = CGRect(x: 0, y: 0, width: self.bounds.size.width*0.5-pad, height: self.bounds.height*0.5-pad)
		for button in self.buttons{
			button.frame = buttonRect
		}
		self.buttons[0].center = CGPoint(x: self.bounds.size.width*0.25, y: self.bounds.size.height*0.25)
		self.buttons[1].center = CGPoint(x: self.bounds.size.width*0.75, y: self.bounds.size.height*0.25)
		self.buttons[2].center = CGPoint(x: self.bounds.size.width*0.25, y: self.bounds.size.height*0.75)
		self.buttons[3].center = CGPoint(x: self.bounds.size.width*0.75, y: self.bounds.size.height*0.75)
		
		for i in 0 ..< self.buttons.count{
			self.buttons[i].setTitleColor(symptomColors[i], for: .normal)
			self.buttons[i].layer.borderColor = symptomColors[i].cgColor
		}
		
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	func initUI() {
		var i = 0
		for i in 0..<self.buttons.count{
			self.buttons[i] = UIButton()
		}
		for i in 0..<self.symptomColors.count{
			self.symptomColors[i] = Style.shared.colorNoEntry
		}
		for button in self.buttons{
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
			button.titleLabel?.textAlignment = .center
			button.titleLabel?.numberOfLines = 3
			button.titleEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
			button.setTitleColor(Style.shared.colorNoEntry, for: .normal)
			button.layer.borderColor = Style.shared.colorNoEntry.cgColor
			button.layer.backgroundColor = UIColor.white.cgColor
			button.layer.cornerRadius = 20
			button.layer.borderWidth = 4
			button.tag = i
			button.addTarget(self, action: #selector(buttonHandler(sender:)), for: .touchUpInside)
			// initialized as hidden
			button.isHidden = true
			self.addSubview(button)
			i += 1
		}
	}
	
	@objc func buttonHandler(sender:UIButton){
		if let d = self.delegate{
			d.didSelectSymptom(index: sender.tag)
		}
	}
	
	func showButtons(){
		for button in self.buttons{
			button.isHidden = false
			button.setTitleColor(Style.shared.blue, for: .normal)
			button.layer.borderColor = Style.shared.blue.cgColor
		}
	}

}

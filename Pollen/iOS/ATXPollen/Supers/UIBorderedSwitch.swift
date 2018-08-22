//
//  UIBorderedSwitch.swift
//  ATXPollen
//
//  Created by Robby Kraft on 8/22/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class UIBorderedSwitch: UIButton {

	var buttonState:CheckButtonState = CheckButtonState.unchecked{
		didSet{
			switch buttonState {
			case .unchecked:
				self.backgroundColor = .lightGray
//				self.checkmark.text = "✕"
				self.buttonSetUnselected()
			default:
				self.backgroundColor = self.color
//				self.checkmark.text = "✓"
				self.buttonSetSelected()
			}
		}
	}

	var color:UIColor = UIColor.black{
		didSet{
			self.setTitleColor(self.color, for: .normal)
			self.layer.borderColor = self.color.cgColor
		}
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
		self.initUI()
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initUI()
	}
	
	func initUI(){
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDown)
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDragEnter)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragOutside)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchCancel)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragExit)
//		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchUpInside)
		self.addTarget(self, action: #selector(toggleSwitch), for: .touchUpInside)
		
		self.setTitleColor(self.color, for: .normal)
		self.layer.borderColor = self.color.cgColor
		self.layer.backgroundColor = UIColor.white.cgColor
		
		self.layer.cornerRadius = 12
		self.layer.borderWidth = 3
		self.sizeToFit()
	}
	
	@objc func toggleSwitch(sender:UIButton){
		switch buttonState {
		case .checked:
			buttonState = .unchecked
//			self.buttonSetUnselected()
		case .unchecked:
			buttonState = .checked
//			self.buttonSetSelected()
		case .thinking: break
		}
	}
	
	@objc func buttonSetSelected(){
		self.layer.backgroundColor = self.color.cgColor
		self.setTitleColor(UIColor.white, for: .normal)
	}
	
	@objc func buttonSetUnselected(){
		self.layer.backgroundColor = UIColor.white.cgColor
		self.setTitleColor(self.color, for: .normal)
	}
	
	
}

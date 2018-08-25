//
//  UIBorderedSwitch.swift
//  ATXPollen
//
//  Created by Robby Kraft on 8/22/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

enum SwitchState {
	case unchecked
	case checked
}

class UIBorderedSwitch: UIButton {

	var buttonState:SwitchState = SwitchState.unchecked{
		didSet{
			switch buttonState {
			case .unchecked: self.buttonSetUnselected()
			case .checked: self.buttonSetSelected()
			}
		}
	}
	
	var isPressing:Bool = false

	var color:UIColor = UIColor.black{
		didSet{
			self.setTitleColor(self.color, for: .normal)
			self.layer.borderColor = self.color.cgColor
		}
	}
	
	var fillColor:UIColor = UIColor.black
	
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
		self.addTarget(self, action: #selector(toggleSwitch), for: .touchUpInside)
		
		self.setTitleColor(self.color, for: .normal)
		self.layer.borderColor = self.color.cgColor
		self.layer.backgroundColor = UIColor.white.cgColor
		
		self.layer.cornerRadius = 12
		self.layer.borderWidth = 3
		self.sizeToFit()
		
		self.imageView?.tintColor = UIColor.white
		self.imageView?.tintAdjustmentMode = .normal
	}
	
	@objc func toggleSwitch(sender:UIButton){
		switch buttonState {
		case .checked: buttonState = .unchecked
		case .unchecked: buttonState = .checked
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.titleLabel?.sizeToFit()
		self.titleLabel?.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5)
		if let imageView = self.imageView, let _ = imageView.image{
			imageView.frame = CGRect(x: 10, y: 0, width: self.bounds.size.height, height: self.bounds.size.height)
			self.titleLabel?.center = CGPoint(x: self.bounds.size.height + (self.bounds.size.width-self.bounds.size.height)*0.5, y: self.bounds.size.height*0.5)
		}
		// unchecked vs. checked or isPressing
		switch buttonState{
		case .checked: self.imageView?.image = self.imageView?.image?.imageWithTint(UIColor.white)
		case .unchecked: self.imageView?.image = self.imageView?.image?.imageWithTint(self.color)
		}
		if isPressing{ self.imageView?.image = self.imageView?.image?.imageWithTint(UIColor.white) }
	}
	
	@objc func buttonSetSelected(){
		self.isPressing = true
		self.layer.backgroundColor = self.fillColor.cgColor
		self.setTitleColor(UIColor.white, for: .normal)
	}
	
	@objc func buttonSetUnselected(){
		self.isPressing = false
		self.layer.backgroundColor = UIColor.white.cgColor
		self.setTitleColor(self.color, for: .normal)
	}
	
}

//
//  UICheckButton.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/19/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

enum CheckButtonState {
	case unchecked
	case checked
	case thinking
}

class UICheckButton: UIButton {

	var buttonState:CheckButtonState = CheckButtonState.unchecked{
		didSet{
			switch buttonState {
			case .unchecked:
				self.backgroundColor = .lightGray
				self.checkmark.text = "✕"
				if let string = uncheckedString{ self.setTitle(string, for: .normal) }
			default:
				self.backgroundColor = self.color
				self.checkmark.text = "✓"
				if let string = checkedString{ self.setTitle(string, for: .normal) }
			}
		}
	}
	
	var checkedString:String?
	var uncheckedString:String?

	var checkmark = UILabel()

	var color:UIColor = UIColor.black{
		didSet{
			self.backgroundColor = self.color
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.imageView?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.height, height: self.bounds.size.height)
		self.titleLabel?.sizeToFit()
		if let label = self.titleLabel{
			if label.frame.size.width > self.bounds.size.width - self.bounds.size.height - 20{
				self.titleLabel?.frame = CGRect(x: self.bounds.size.height, y: 0, width: self.bounds.size.width - self.bounds.size.height, height: self.bounds.size.height)
			}
		}
		self.titleLabel?.center = CGPoint(x: self.bounds.size.height + (self.bounds.size.width - self.bounds.size.height)*0.5, y: self.bounds.size.height*0.5)
		
		self.addSubview(checkmark)
		checkmark.sizeToFit()
		checkmark.center = CGPoint(x: self.bounds.size.height*0.5, y: self.bounds.size.height*0.5)
	}
	
	func initUI(){
		
		self.checkmark.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P48)
		self.checkmark.textColor = .white
		self.checkmark.text = "✓"
		
		self.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDown)
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDragEnter)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragOutside)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchCancel)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragExit)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchUpInside)
		
		self.setTitleColor(UIColor.white, for: .normal)
		
		self.backgroundColor = self.color
		self.sizeToFit()
	}
	
	@objc func buttonSetSelected(){
		self.setTitleColor(Style.shared.athensGray, for: .normal)
	}
	
	@objc func buttonSetUnselected(){
//		self.setTitleColor(self.color, for: .normal)
		self.setTitleColor(UIColor.white, for: .normal)
	}
	
}

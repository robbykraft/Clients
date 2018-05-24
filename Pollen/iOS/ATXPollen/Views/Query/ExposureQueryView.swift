//
//  ExposureQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class ExposureQueryView: UIView {

	let topQuestionLabel = UILabel()
	let responseButtons = [UIBorderedButton(), UIBorderedButton(), UIBorderedButton(), UIBorderedButton()]

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
	
	func initUI(){
		topQuestionLabel.textColor = UIColor.black
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		topQuestionLabel.text = "Exposed to any of these today?"
		
		// buttons
		let labels = ["dust","molds","virus","pets"]
		for i in 0 ..< responseButtons.count {
			let button = responseButtons[i]
			button.setTitle(labels[i], for: .normal)
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
			button.color = UIColor.black
		}
		self.addSubview(topQuestionLabel)
		for button in responseButtons { self.addSubview(button) }
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let topPadding:CGFloat = 20
		let belowQuestionPad:CGFloat = 15
		let buttonPad:CGFloat = 2
		
		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding)
		let buttonContent = CGRect(x: 0, y: topQuestionLabel.frame.bottom + belowQuestionPad, width: self.bounds.size.width, height: self.bounds.size.height - topQuestionLabel.frame.bottom - belowQuestionPad)
		let buttonX:CGFloat = self.bounds.size.width*0.16666
		let buttonW:CGFloat = self.bounds.size.width*0.6666
		let buttonH:CGFloat = buttonContent.size.height / CGFloat(responseButtons.count) - buttonPad
		var i:CGFloat = 0
		for button in responseButtons{
			button.frame = CGRect(x: buttonX, y: buttonContent.origin.y + i * (buttonH+buttonPad), width: buttonW, height: buttonH)
			i += 1
		}
	}

}

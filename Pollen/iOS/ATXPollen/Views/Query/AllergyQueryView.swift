//
//  AllergyQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class AllergyQueryView: UIView {

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
		topQuestionLabel.text = "How are your allergies today?"

		// buttons
		let labels = ["none","light","medium","severe"]
		let colors = [UIColor.black, Style.shared.colorLow, Style.shared.colorMedium, Style.shared.colorHeavy]
		for i in 0 ..< responseButtons.count {
			let button = responseButtons[i]
			button.setTitle(labels[i], for: .normal)
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
			button.color = colors[i]
		}

		self.addSubview(topQuestionLabel)
		for button in responseButtons { self.addSubview(button) }
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let topPadding:CGFloat = 20
		let btnPad:CGFloat = 2
		let btnAreaPad:CGFloat = 10

		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding)
		let buttonContent = CGRect(x: btnAreaPad, y: topQuestionLabel.frame.bottom + btnAreaPad, width: self.bounds.size.width - btnAreaPad*2, height: self.bounds.size.height - topQuestionLabel.frame.bottom - btnAreaPad*2)
		
		if let noneButton = responseButtons.first{
			noneButton.frame = CGRect(x: buttonContent.origin.x, y: buttonContent.origin.y + buttonContent.size.height*2/3+btnPad, width: buttonContent.size.width, height: buttonContent.size.height/3-btnPad)
		}
		let buttonsX:CGFloat = buttonContent.origin.x
		let buttonW:CGFloat = buttonContent.size.width / 3 - CGFloat(responseButtons.count-2)*2
		let buttonH:CGFloat = buttonContent.size.height * 2/3 - btnPad
		for i in 1..<responseButtons.count{
			responseButtons[i].frame = CGRect(x: buttonsX + (buttonW+btnPad*2)*CGFloat(i-1), y: buttonContent.origin.y+btnPad, width: buttonW, height: buttonH)
		}
	}
}

//
//  AllergyQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

protocol AllergyQueryDelegate{
	func allergyQueryDidChange(rating:SymptomRating?)
}

class AllergyQueryView: UIView {
	
	var delegate:AllergyQueryDelegate?

	let topQuestionLabel = UILabel()
	let responseLabel = UILabel()
	let responseButtons = [UIBorderedSwitch(), UIBorderedSwitch(), UIBorderedSwitch(), UIBorderedSwitch()]

	let buttonLabels = ["no allergies","light","medium","severe"]
//	let colors = [UIColor.black, Style.shared.colorLow, Style.shared.colorMedium, Style.shared.colorHeavy]
	let colors = [Style.shared.green, Style.shared.yellow, Style.shared.orange, Style.shared.red]

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
		topQuestionLabel.text = "How are your allergies?"

		responseLabel.textColor = UIColor.black
		responseLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P21)
		responseLabel.text = "no response"

		// buttons
		for i in 0 ..< responseButtons.count {
			let button = responseButtons[i]
			button.tag = i
			button.setTitle(buttonLabels[i], for: .normal)
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P15)
			button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
			button.color = colors[i]
			button.fillColor = colors[i]
		}

		self.addSubview(topQuestionLabel)
		self.addSubview(responseLabel)
		for button in responseButtons { self.addSubview(button) }
	}
	
	@objc func buttonDidPress(sender:UIBorderedSwitch){
		responseButtons.filter({ $0 != sender }).forEach({ $0.buttonState = .unchecked })
		if let checkedButton = responseButtons.filter({ $0.buttonState == .checked }).first{
			responseLabel.text = checkedButton.titleLabel?.text
			responseLabel.textColor = colors[checkedButton.tag]
			self.delegate?.allergyQueryDidChange(rating: SymptomRating(rawValue: checkedButton.tag))
		} else{
			responseLabel.text = "no response"
			responseLabel.textColor = UIColor.black
			self.delegate?.allergyQueryDidChange(rating: nil)
		}
		self.setNeedsLayout()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let topPadding:CGFloat = 20
		let btnPad:CGFloat = 2
		let btnAreaPadX:CGFloat = 25
		let btnAreaPadY:CGFloat = 15
		let txtPad:CGFloat = 7

		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding)
		responseLabel.sizeToFit()
		responseLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topQuestionLabel.center.y + topQuestionLabel.frame.size.height*0.5 + responseLabel.frame.size.height * 0.5 + txtPad)
		let buttonContent = CGRect(x: btnAreaPadX, y: responseLabel.frame.bottom + btnAreaPadY, width: self.bounds.size.width - btnAreaPadX*2, height: self.bounds.size.height - responseLabel.frame.bottom - btnAreaPadY*2)
		
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

//
//  WhatSeasonsView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/19/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class WhatSeasonsView: UIView {
	
	let topQuestionLabel = UILabel()
//	let paragraphText = UITextView()
	let seasonsButtons = [UICheckButton(), UICheckButton(), UICheckButton(), UICheckButton()]
	let getStartedButton = UIBorderedButton()

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
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		topQuestionLabel.text = "Which seasons do you experience allergies?"
		
		seasonsButtons.enumerated().forEach { (offset, button) in
			button.setTitle(PollenTypeSeason(rawValue: offset)?.asString(), for: .normal)
			self.addSubview(button)
		}
		
//		paragraphText.textColor = UIColor.black
//		paragraphText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
//		paragraphText.text = "Which seasons do you experience allergies?"
		
		getStartedButton.setTitle("get started", for: .normal)
		getStartedButton.sizeToFit()
		getStartedButton.frame = CGRect(x: 0, y: 0, width: getStartedButton.bounds.size.width+40, height: getStartedButton.bounds.size.height+15)
		getStartedButton.color = .black
		
		self.addSubview(topQuestionLabel)
		
//		self.addSubview(paragraphText)
		self.addSubview(getStartedButton)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		let topPadding:CGFloat = 20
//		let btnAreaPadX:CGFloat = 25
//		let btnAreaPadY:CGFloat = 15
		
		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding)
//		let belowContent = CGRect(x: btnAreaPadX, y: topQuestionLabel.frame.bottom + btnAreaPadY, width: self.bounds.size.width - btnAreaPadX*2, height: self.bounds.size.height - topQuestionLabel.frame.bottom - btnAreaPadY*2)
//		paragraphText.frame = belowContent
		
		seasonsButtons.enumerated().forEach { (offset, button) in
			button.sizeToFit()
			button.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: button.bounds.size.height+30)
			button.center = CGPoint(x: self.bounds.size.width*0.5, y: topQuestionLabel.frame.bottom + button.bounds.size.height*0.5 + button.bounds.size.height*CGFloat(offset))
		}
		
		getStartedButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - getStartedButton.frame.size.height*0.5 - 10)
		
//		paragraphText.frame = CGRect(x: btnAreaPadX, y: 0, width: self.bounds.size.width - btnAreaPadX*2, height: enableNotificationsButton.frame.origin.y)
	}


}

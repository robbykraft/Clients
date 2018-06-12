//
//  IntroAllergyTrackView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class IntroAllergyTrackView: UIView {

	let topQuestionLabel = UILabel()
	let paragraphText = UITextView()
	let dailyReminderButton = UIBorderedButton()
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
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		topQuestionLabel.text = "discover your allergies"

		paragraphText.textColor = UIColor.black
		paragraphText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
		paragraphText.text = "Tracking your allergies every day during allergy season can help you figure out what you are allergic to and better know yourself."

		dailyReminderButton.setTitle("setup daily reminder", for: .normal)
		dailyReminderButton.sizeToFit()
		dailyReminderButton.frame = CGRect(x: 0, y: 0, width: dailyReminderButton.bounds.size.width+40, height: dailyReminderButton.bounds.size.height+15)
		dailyReminderButton.color = .black

		getStartedButton.setTitle("let's go", for: .normal)
		getStartedButton.sizeToFit()
		getStartedButton.frame = CGRect(x: 0, y: 0, width: getStartedButton.bounds.size.width+40, height: getStartedButton.bounds.size.height+15)
		getStartedButton.color = .black

		self.addSubview(topQuestionLabel)
		self.addSubview(paragraphText)
		self.addSubview(dailyReminderButton)
		self.addSubview(getStartedButton)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let topPadding:CGFloat = 20
		let btnAreaPadX:CGFloat = 25
		let btnAreaPadY:CGFloat = 15
		
		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding)
		let belowContent = CGRect(x: btnAreaPadX, y: topQuestionLabel.frame.bottom + btnAreaPadY, width: self.bounds.size.width - btnAreaPadX*2, height: self.bounds.size.height - topQuestionLabel.frame.bottom - btnAreaPadY*2)
		paragraphText.frame = belowContent

		dailyReminderButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.6)
		getStartedButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.85)
	}
}

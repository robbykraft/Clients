//
//  IntroAllergyTrackView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class IntroAllergyTrackView: UIView {

	let paragraphText = UITextView()
	let enableNotificationsButton = UICheckButton()
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
		paragraphText.textColor = UIColor.black
		paragraphText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		paragraphText.text = "Together we can figure out what's triggering your allergies, giving you a leg up on the allergy season.\n\nAll it takes is one simple question asked daily and can be turned off at any time."

		enableNotificationsButton.uncheckedString = "enable notifications"
		enableNotificationsButton.checkedString = "notifications enabled"
		enableNotificationsButton.color = Style.shared.blue
		enableNotificationsButton.buttonState = .unchecked
		enableNotificationsButton.sizeToFit()
		enableNotificationsButton.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: enableNotificationsButton.bounds.size.height+15)
		
		getStartedButton.setTitle("get started", for: .normal)
		getStartedButton.sizeToFit()
		getStartedButton.frame = CGRect(x: 0, y: 0, width: getStartedButton.bounds.size.width+40, height: getStartedButton.bounds.size.height+15)
		getStartedButton.color = .black
		
		PollenNotifications.shared.isLocalEnabled { (enabled) in
			self.updateCheckedButton(enabled)
		}

		enableNotificationsButton.addTarget(self, action: #selector(authorizeNotificationsHandler), for: .touchUpInside)

		self.addSubview(paragraphText)
		self.addSubview(enableNotificationsButton)
		self.addSubview(getStartedButton)
	}
	
	func updateCheckedButton(_ checked:Bool){
		if checked{ self.enableNotificationsButton.buttonState = .checked }
		else      { self.enableNotificationsButton.buttonState = .unchecked }
	}

	@objc func authorizeNotificationsHandler(){
		PollenNotifications.shared.enableLocalNotifications { (success) in
			self.updateCheckedButton(success)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let btnAreaPadX:CGFloat = 25
		enableNotificationsButton.sizeToFit()
		enableNotificationsButton.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: enableNotificationsButton.bounds.size.height+30)

		getStartedButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - getStartedButton.frame.size.height*0.5 - 10)
		enableNotificationsButton.center = CGPoint(x: self.bounds.size.width*0.5, y: getStartedButton.center.y - getStartedButton.frame.size.height*0.5 - enableNotificationsButton.frame.size.height * 0.5 - 15)
		
		paragraphText.frame = CGRect(x: btnAreaPadX, y: 0, width: self.bounds.size.width - btnAreaPadX*2, height: enableNotificationsButton.frame.origin.y)
	}

}

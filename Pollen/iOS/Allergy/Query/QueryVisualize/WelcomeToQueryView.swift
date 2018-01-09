//
//  WelcomeToQueryView.swift
//  Allergy
//
//  Created by Robby on 1/9/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

protocol WelcomeViewProtocol {
	func welcomeViewDoneButtonDidPress()
}

class WelcomeToQueryView: UIView {

	let titleText = UILabel()
	let bodyText = UITextView()
	let privateText = UITextView()
	let startButton = UIButton()
	
	var delegate:WelcomeViewProtocol?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initUI()
	}
	
	func initUI(){
		self.addSubview(titleText)
		self.addSubview(bodyText)
		self.addSubview(privateText)
		self.addSubview(startButton)
		
		titleText.text = "Welcome!"
		bodyText.text = "Track your allergy responses in this new section and see it charted over time."
		privateText.text = "Your data is private to your device"
		
		titleText.textColor = Style.shared.blue
		bodyText.textColor = Style.shared.blue
		privateText.textColor = Style.shared.blue
		titleText.backgroundColor = .clear
		bodyText.backgroundColor = .clear
		privateText.backgroundColor = .clear

		bodyText.textAlignment = .center
		privateText.textAlignment = .center

		titleText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P48)
		bodyText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		privateText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		startButton.setTitle("Let's Go", for: .normal)
		startButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		startButton.setTitleColor(Style.shared.blue, for: .normal)
		startButton.layer.borderColor = Style.shared.blue.cgColor
		startButton.layer.backgroundColor = UIColor.white.cgColor
		startButton.layer.cornerRadius = 20
		startButton.layer.borderWidth = 4
		
		startButton.addTarget(self, action: #selector(doneButtonHandler), for: .touchUpInside)
		startButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDown)
		startButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDragEnter)
		startButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragOutside)
		startButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchCancel)
		startButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragExit)
		startButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchUpInside)
	}
	
	@objc func doneButtonHandler(){
		self.delegate?.welcomeViewDoneButtonDidPress()
	}
	
	func doneButtonSetSelected(){
		self.startButton.layer.backgroundColor = Style.shared.blue.cgColor
		startButton.setTitleColor(UIColor.white, for: .normal)
	}
	func doneButtonSetUnselected(){
		self.startButton.layer.backgroundColor = UIColor.white.cgColor
		startButton.setTitleColor(Style.shared.blue, for: .normal)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let pad:CGFloat = 30
		titleText.sizeToFit()
		bodyText.sizeToFit()
		titleText.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.1)
		bodyText.frame = CGRect(x: self.bounds.size.width*0.15, y: titleText.frame.bottom + pad, width:self.bounds.size.width*0.7, height:self.bounds.size.height*0.5)

		privateText.sizeToFit()
		privateText.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - privateText.frame.size.height*1.33)

		startButton.sizeToFit()
		startButton.frame = CGRect(x: 0, y: 0, width: startButton.frame.size.width*2, height: startButton.frame.size.height*1.5)
		startButton.center = CGPoint(x: self.bounds.size.width*0.5, y: privateText.frame.origin.y - startButton.frame.size.height*0.5 - pad)
		
	}

}

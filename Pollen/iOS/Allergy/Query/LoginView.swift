//
//  LoginView.swift
//  Allergy
//
//  Created by Robby on 10/17/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class LoginView: UIView {

	let helperText = UILabel()
	let loginButton = UIButton()

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
	
	func initUI() {
		helperText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		loginButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		helperText.text = "Track your allergies"
		loginButton.setTitle("Login", for: .normal)

		helperText.sizeToFit()
		loginButton.sizeToFit()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		loginButton.center = self.center
	}
}

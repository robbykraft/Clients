//
//  ExposureQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

protocol ExposureQueryDelegate{
	func exposureQueryDidChange(exposures:[Exposures]?, date:Date?)
}

class ExposureQueryView: UIView {
	
	var delegate:ExposureQueryDelegate?

	// please set this date!! this is used by the delegate
	var date:Date?

	let topQuestionLabel = UILabel()
	let responseButtons = [UIBorderedSwitch(), UIBorderedSwitch(), UIBorderedSwitch(), UIBorderedSwitch(), UIBorderedSwitch()]

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
		topQuestionLabel.text = "Exposed to any of these today?"
		
		// buttons
		let exposureTypes:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})
		for i in 0 ..< responseButtons.count {
			let button = responseButtons[i]
			button.setTitle(exposureTypes[i].asString(), for: .normal)
			button.setImage(UIImage(named: exposureTypes[i].asString()), for: .normal)
			button.tag = i
			button.fillColor = Style.shared.blue
			button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
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
	
	@objc func buttonDidPress(sender:UIBorderedSwitch){
		let selectedExposures = responseButtons
			.filter({ $0.buttonState == .checked })
			.compactMap({  Exposures(rawValue: $0.tag) })
		if selectedExposures.count > 0 {
			self.delegate?.exposureQueryDidChange(exposures: selectedExposures, date:self.date)
		} else {
			self.delegate?.exposureQueryDidChange(exposures: nil, date:self.date)
		}
	}

}

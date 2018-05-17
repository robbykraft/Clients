//
//  AllergyQueryView.swift
//  Allergy
//
//  Created by Robby Kraft on 5/15/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class AllergyQueryView: UIView {

	let dateLabel = UILabel()
	let topQuestionLabel = UILabel()
	var date:Date = Date()
	let dateNextButton = UIButton()
	let datePrevButton = UIButton()
	let responseSlider = UIImageView()
	let responseText = UILabel()

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
		responseText.textColor = UIColor.black
		responseText.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)

		// buttons
//		let labels = ["severe","medium","light","none"]

		self.addSubview(responseText)
		self.addSubview(responseSlider)
		self.addSubview(topQuestionLabel)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.formatQuestion()

		let topPadding:CGFloat = 35
		let belowQuestionPad:CGFloat = 25
		let belowSliderPad:CGFloat = 60

		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding + dateLabel.frame.size.height*0.5)

		responseSlider.image = UIImage(named: "slider-mockup")
		responseSlider.frame = CGRect(x: 0, y: 0, width: self.frame.size.width-100, height: (self.frame.size.width-100)/5.8)
		responseSlider.center = CGPoint(x: self.frame.size.width*0.5, y: topQuestionLabel.frame.bottom + belowQuestionPad + responseSlider.frame.size.height*0.5)
		responseText.text = "light"
		responseText.sizeToFit()
		responseText.center = responseSlider.center
		responseText.center.y += belowSliderPad
	}


	func formatQuestion(){
		if Calendar.current.isDateInToday(self.date){
			topQuestionLabel.text = "how are your allergies today?"
		} else if Calendar.current.isDateInYesterday(self.date){
			topQuestionLabel.text = "how were your allergies yesterday?"
		} else if self.date.timeIntervalSinceNow < Date().timeIntervalSinceNow{
			topQuestionLabel.text = "how were your allergies?"
		} else{
			topQuestionLabel.text = "how will your allergies be?"
		}
		topQuestionLabel.sizeToFit()
	}


	@objc func dateNextButtonHandler(){
		var components = DateComponents()
		components.setValue(1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.setNeedsLayout()
	}

	@objc func datePrevButtonHandler(){
		var components = DateComponents()
		components.setValue(-1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.setNeedsLayout()
	}
}


//class AllergyQueryView: UIView {
//
//	let dateLabel = UILabel()
//	let topQuestionLabel = UILabel()
//	var date:Date = Date()
//	let dateNextButton = UIButton()
//	let datePrevButton = UIButton()
//	let responseButtons = [UIBorderedButton(), UIBorderedButton(), UIBorderedButton(), UIBorderedButton()]
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		initUI()
//	}
//	convenience init() {
//		self.init(frame: CGRect.zero)
//	}
//	required init(coder aDecoder: NSCoder) {
//		fatalError("This class does not support NSCoding")
//	}
//	func initUI(){
//		topQuestionLabel.textColor = UIColor.black
//		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
//		dateLabel.textColor = UIColor.gray
//		dateLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P15)
//		dateNextButton.setTitleColor(UIColor.black, for: .normal)
//		datePrevButton.setTitleColor(UIColor.black, for: .normal)
//		dateNextButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
//		datePrevButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
//		dateNextButton.setTitle("▶︎", for: .normal)
//		datePrevButton.setTitle("◀︎", for: .normal)
//		dateNextButton.addTarget(self, action: #selector(dateNextButtonHandler), for: .touchUpInside)
//		datePrevButton.addTarget(self, action: #selector(datePrevButtonHandler), for: .touchUpInside)
//
//		// buttons
//		let labels = ["severe","medium","light","none"]
//		let colors = [Style.shared.colorHeavy, Style.shared.colorMedium, Style.shared.colorLow, Style.shared.blue]
//		for i in 0 ..< responseButtons.count {
//			let button = responseButtons[i]
//			button.setTitle(labels[i], for: .normal)
//			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
//			button.color = colors[i]
//		}
//
////		self.addSubview(dateLabel)
////		self.addSubview(datePrevButton)
////		self.addSubview(dateNextButton)
//		self.addSubview(topQuestionLabel)
//		for button in responseButtons { self.addSubview(button) }
//	}
//
//	override func layoutSubviews() {
//		super.layoutSubviews()
//
//		self.formatQuestion()
//
//		let topPadding:CGFloat = 20
//		let belowQuestionPad:CGFloat = 15
//		let buttonPad:CGFloat = 2
//
//		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: topPadding + dateLabel.frame.size.height*0.5)
//		let buttonContent = CGRect(x: 0, y: topQuestionLabel.frame.bottom + belowQuestionPad, width: self.bounds.size.width, height: self.bounds.size.height - topQuestionLabel.frame.bottom - belowQuestionPad)
//		let buttonX:CGFloat = self.bounds.size.width*0.16666
//		let buttonW:CGFloat = self.bounds.size.width*0.6666
//		let buttonH:CGFloat = buttonContent.size.height / CGFloat(responseButtons.count) - buttonPad
//		var i:CGFloat = 0
//		for button in responseButtons{
//			button.frame = CGRect(x: buttonX, y: buttonContent.origin.y + i * (buttonH+buttonPad), width: buttonW, height: buttonH)
//			i += 1
//		}
//
////		let dateFormatter = DateFormatter()
////		dateFormatter.dateFormat = "MMM d, yyyy"
////		dateLabel.text = dateFormatter.string(from: self.date)
////		dateLabel.sizeToFit()
////		dateLabel.center = CGPoint(x: w * 0.5, y: topQuestionLabel.frame.origin.y + topQuestionLabel.frame.size.height + dateLabel.frame.size.height*0.5 + 10)
////		datePrevButton.sizeToFit()
////		dateNextButton.sizeToFit()
////		datePrevButton.center = CGPoint(x: dateLabel.center.x - dateLabel.frame.size.width*0.5-30, y: dateLabel.center.y)
////		dateNextButton.center = CGPoint(x: dateLabel.center.x + dateLabel.frame.size.width*0.5+30, y: dateLabel.center.y)
//
//
////		let w = self.bounds.size.width
////		let h = self.bounds.size.height
//	}
//
//
//	func formatQuestion(){
//		if Calendar.current.isDateInToday(self.date){
//			topQuestionLabel.text = "how are your allergies today?"
//		} else if Calendar.current.isDateInYesterday(self.date){
//			topQuestionLabel.text = "how were your allergies yesterday?"
//		} else if self.date.timeIntervalSinceNow < Date().timeIntervalSinceNow{
//			topQuestionLabel.text = "how were your allergies?"
//		} else{
//			topQuestionLabel.text = "how will your allergies be?"
//		}
//		topQuestionLabel.sizeToFit()
//	}
//
//
//	@objc func dateNextButtonHandler(){
//		var components = DateComponents()
//		components.setValue(1, for: .day)
//		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
//			self.date = newDate
//		}
//		self.setNeedsLayout()
//	}
//
//	@objc func datePrevButtonHandler(){
//		var components = DateComponents()
//		components.setValue(-1, for: .day)
//		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
//			self.date = newDate
//		}
//		self.setNeedsLayout()
//	}
//
//}

//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol QueryViewDelegate{
	func queryViewDateDidChange(date:Date)
}

class QueryView: UIView{
	
	var delegate:QueryViewDelegate?
	
	// query view
	let dateLabel = UILabel()
	let topQuestionLabel = UILabel()
	var date:Date = Date()
	let dateNextButton = UIButton()
	let datePrevButton = UIButton()
	let segmentedControl = UISegmentedControl(items: ["My Allergies","My Charts"])
	let segmentedHR = UIView()
	
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
		dateLabel.textColor = UIColor.gray
		dateLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P15)
		dateNextButton.setTitleColor(UIColor.black, for: .normal)
		datePrevButton.setTitleColor(UIColor.black, for: .normal)
		dateNextButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		datePrevButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		dateNextButton.setTitle("▶︎", for: .normal)
		datePrevButton.setTitle("◀︎", for: .normal)
		dateNextButton.addTarget(self, action: #selector(dateNextButtonHandler), for: .touchUpInside)
		datePrevButton.addTarget(self, action: #selector(datePrevButtonHandler), for: .touchUpInside)
		segmentedHR.backgroundColor = Style.shared.blue
		
		// buttons
		let labels = ["Severe","Medium","Light","None"]
		let colors = [Style.shared.colorHeavy, Style.shared.colorMedium, Style.shared.colorLow, Style.shared.blue]
		for i in 0 ..< responseButtons.count {
			let button = responseButtons[i]
			button.setTitle(labels[i], for: .normal)
			button.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
			button.color = colors[i]
		}
		

		self.addSubview(segmentedControl)
		self.addSubview(segmentedHR)
//		self.addSubview(dateLabel)
//		self.addSubview(datePrevButton)
//		self.addSubview(dateNextButton)
		self.addSubview(topQuestionLabel)
		for button in responseButtons { self.addSubview(button) }

	}
	
	func formatQuestion(){
		if Calendar.current.isDateInToday(self.date){
			topQuestionLabel.text = "How are your allergies today?"
		} else if Calendar.current.isDateInYesterday(self.date){
			topQuestionLabel.text = "How were your allergies yesterday?"
		} else if self.date.timeIntervalSinceNow < Date().timeIntervalSinceNow{
			// date in the past
			topQuestionLabel.text = "How were your allergies?"
		} else{
			// date in the future
			topQuestionLabel.text = "How will your allergies be?"
		}

		topQuestionLabel.sizeToFit()

		let segmentPadding:CGFloat = 20
		topQuestionLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: segmentedControl.frame.origin.y + segmentedControl.frame.size.height + dateLabel.frame.size.height*0.5 + segmentPadding)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		
		let w = self.bounds.size.width
		segmentedControl.center = CGPoint(x: w * 0.5, y: 20)
		segmentedHR.frame = CGRect(x: 0, y: segmentedControl.frame.origin.y + segmentedControl.frame.size.height-1, width: self.bounds.size.width, height: 1)

		self.formatQuestion()

//		let dateFormatter = DateFormatter()
//		dateFormatter.dateFormat = "MMM d, yyyy"
//		dateLabel.text = dateFormatter.string(from: self.date)
//		dateLabel.sizeToFit()
//		dateLabel.center = CGPoint(x: w * 0.5, y: topQuestionLabel.frame.origin.y + topQuestionLabel.frame.size.height + dateLabel.frame.size.height*0.5 + 10)
//		datePrevButton.sizeToFit()
//		dateNextButton.sizeToFit()
//		datePrevButton.center = CGPoint(x: dateLabel.center.x - dateLabel.frame.size.width*0.5-30, y: dateLabel.center.y)
//		dateNextButton.center = CGPoint(x: dateLabel.center.x + dateLabel.frame.size.width*0.5+30, y: dateLabel.center.y)
		
		
		let buttonTop:CGFloat = topQuestionLabel.frame.bottom + 10
		let buttonX:CGFloat = self.bounds.width*0.25
		let buttonW:CGFloat = self.bounds.width*0.5
		let buttonH:CGFloat = 40
		var i:CGFloat = 0
		for button in responseButtons{
			button.frame = CGRect(x: buttonX, y: buttonTop + i * (buttonH+4), width: buttonW, height: buttonH)
			i += 1
		}
	}
	
	@objc func dateNextButtonHandler(){
		var components = DateComponents()
		components.setValue(1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.delegate?.queryViewDateDidChange(date:self.date)
		self.setNeedsLayout()
	}
	
	@objc func datePrevButtonHandler(){
		var components = DateComponents()
		components.setValue(-1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.delegate?.queryViewDateDidChange(date:self.date)
		self.setNeedsLayout()
	}
	

}

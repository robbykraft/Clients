//
//  MyAllergiesView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 8/17/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class MyAllergiesView: UIView {
	
	var date:Date?

//	let scrollView = UIScrollView()
	
	let addEntryButton = UIBorderedButton()

	var myAllergyFaceView = UIImageView()
	let myAllergyLabel = UILabel()

	var exposureImageViews:[UIImageView] = []
	var exposuresLabel = UILabel()

	var updateSymptomButton = UIButton()
	var updateExposureButton = UIButton()

	// data
	var exposures:[Exposures] = []
	var symptom:SymptomRating?

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
		myAllergyLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		myAllergyLabel.textColor = .black
		myAllergyLabel.text = ""

		addEntryButton.setTitle("add entry for today", for: .normal)
		addEntryButton.setTitleColor(.black, for: .normal)
		addEntryButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		addEntryButton.addTarget(self, action: #selector(addEntryHandler), for: .touchUpInside)
		
		exposuresLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		exposuresLabel.textColor = .black
		exposuresLabel.text = ""
		

		self.addSubview(myAllergyFaceView)
		self.addSubview(myAllergyLabel)
		self.addSubview(exposuresLabel)
		self.addSubview(addEntryButton)

		updateSymptomButton.addTarget(self, action: #selector(updateSymptomDidPress), for: .touchUpInside)
		updateExposureButton.addTarget(self, action: #selector(updateExposureDidPress), for: .touchUpInside)
		[updateSymptomButton, updateExposureButton].forEach({
			$0.backgroundColor = .clear
			self.addSubview($0)
		})
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let exposureCenter = [
			CGPoint(x: self.bounds.size.width*0.75, y: self.bounds.size.height*0.4),
			CGPoint(x: self.bounds.size.width*0.6, y: self.bounds.size.height*0.4),
			CGPoint(x: self.bounds.size.width*0.9, y: self.bounds.size.height*0.4),
			CGPoint(x: self.bounds.size.width*0.675, y: self.bounds.size.height*0.65),
			CGPoint(x: self.bounds.size.width*0.825, y: self.bounds.size.height*0.65)
		]
		for view in exposureImageViews{
			view.removeFromSuperview()
		}
		exposureImageViews = []

		addEntryButton.isHidden = true
		addEntryButton.sizeToFit()
		addEntryButton.frame.size.height += 12
		addEntryButton.frame.size.width += 50
		addEntryButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5)
		
		let faceViewSize:CGFloat = self.bounds.size.height*0.6
		myAllergyFaceView.frame = CGRect(x: 0, y: 0, width: faceViewSize, height: faceViewSize)
		myAllergyFaceView.center = CGPoint(x: self.bounds.size.width*0.25, y: faceViewSize * 0.6)
		myAllergyLabel.sizeToFit()

		updateSymptomButton.isHidden = false
		updateExposureButton.isHidden = false
		updateSymptomButton.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width*0.5, height: self.bounds.size.height)
		updateExposureButton.frame = CGRect(x: self.bounds.size.width*0.5, y: 0, width: self.bounds.size.width*0.5, height: self.bounds.size.height)

		exposures.enumerated().forEach { (offset, exposure) in
			if let image = UIImage(named: exposure.asString()){
				let exposureView = UIImageView(image: image)
				exposureView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width*0.125, height: self.bounds.size.width*0.125)
				exposureView.center = exposureCenter[offset]
				if exposures.count > 3 { exposureView.center.y -= self.bounds.size.width*0.125*0.5 }
				self.addSubview(exposureView)
				exposureImageViews.append(exposureView)
			}
		}
		
		exposuresLabel.text = (exposures.count == 0) ? "no exposures" : "exposures"
		exposuresLabel.sizeToFit()
		if exposures.count == 0 { exposuresLabel.center.y = self.bounds.size.height*0.5 }
		
		if let symptom = self.symptom{
			var color = UIColor.black
			switch symptom.rawValue{
			case 0: color = Style.shared.green
			case 1: color = Style.shared.yellow
			case 2: color = Style.shared.orange
			case 3: color = Style.shared.red
			default: break
			}
			myAllergyFaceView.image = UIImage(named: "face\(symptom.rawValue)")?.imageWithTint(color)
			myAllergyLabel.text = symptom.rawValue == 0 ? symptom.asString() + " today" : "my allergies were " + symptom.asString()
			myAllergyLabel.sizeToFit()
		} else{
			// no allergy response this day
			myAllergyFaceView.image = nil
			myAllergyLabel.text = "no response"
			myAllergyLabel.sizeToFit()

			if(exposures.count == 0){
				// no allergies or exposures today
				myAllergyLabel.text = ""
				exposuresLabel.text = ""
				addEntryButton.isHidden = false
				updateSymptomButton.isHidden = true
				updateExposureButton.isHidden = true
			}
		}
		myAllergyLabel.center = CGPoint(x: self.bounds.size.width*0.25, y: self.bounds.size.height*0.8)
		exposuresLabel.center = CGPoint(x: self.bounds.size.width*0.75, y: self.bounds.size.height*0.8)
		
	}
	
	@objc func updateSymptomDidPress(sender:UIButton){
		if let date = self.date{
			NotificationCenter.default.post(name: .queryRequestSymptom, object: nil, userInfo: ["date":date])
		}
	}
	@objc func updateExposureDidPress(sender:UIButton){
		if let date = self.date{
			NotificationCenter.default.post(name: .queryRequestExposure, object: nil, userInfo: ["date":date])
		}
	}
	@objc func addEntryHandler(sender:UIButton){
		if let date = self.date{
			NotificationCenter.default.post(name: .queryRequestSymptomAndExposure, object: nil, userInfo: ["date":date])
		}
	}
	
	func reloadData(with date:Date){
		self.date = date
	
		// find the matching day in ChartData index
		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		guard let dayIndex = ChartData.shared.yearlyIndex(for: date) else { return }

		// exposures
		exposures = ChartData.shared.exposureDailyData[dayIndex].enumerated().compactMap { (offset, element) -> Exposures? in
			if element { return Exposures(rawValue: offset)! }
			return nil
		}

		// my allergies
		if let symptomValue = ChartData.shared.allergyDataValues[dayIndex]{
			symptom = SymptomRating(rawValue: symptomValue)
		} else{
			symptom = nil
		}
		self.setNeedsLayout()
	}

}

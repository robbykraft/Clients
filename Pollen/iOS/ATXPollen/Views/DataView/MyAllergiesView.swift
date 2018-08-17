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

//	let dateLabel = UILabel()
	let myDataLabel = UILabel()
	let scrollView = UIScrollView()
	
	let addEntryButton = UIButton()
	
	var imageViews:[UIImageView] = []
	var myAllergyFaceView = UIImageView()
	
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
//		dateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
//		dateLabel.textColor = .black
		myDataLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		myDataLabel.textColor = .black
		myDataLabel.text = "my allergies"
		
		addEntryButton.setTitle("add entry for today", for: .normal)
		addEntryButton.setTitleColor(.black, for: .normal)
		addEntryButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11)
		addEntryButton.addTarget(self, action: #selector(addEntryHandler), for: .touchUpInside)
		addEntryButton.sizeToFit()
		
		self.addSubview(myAllergyFaceView)
		
//		self.addSubview(dateLabel)
		self.addSubview(myDataLabel)
		self.addSubview(addEntryButton)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		dateLabel.sizeToFit()
//		dateLabel.frame.origin = CGPoint(x: 20, y: 0)
		myDataLabel.sizeToFit()
		myDataLabel.frame.origin = CGPoint(x: 20, y: 0)
		addEntryButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.75)
		
		myAllergyFaceView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.height*0.5, height: self.bounds.size.height*0.5)
		myAllergyFaceView.center = CGPoint(x: self.bounds.size.height*0.5, y: self.bounds.size.height*0.5)
	}
	
	@objc func addEntryHandler(sender:UIButton){
		if let date = self.date{
			let allergyQueryView = AllergyQueryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width*0.66, height: UIScreen.main.bounds.size.height*0.66))
			let formatter = DateFormatter()
			formatter.dateFormat = "EEEE, MMM d, yyyy"
			let alert = PopAlertView(title: formatter.string(from: date), view: allergyQueryView)
//			introAllergyView.getStartedButton.addTarget(self, action: #selector(openNextScreen), for: .touchUpInside)
			alert.show(animated: true)
		}
	}
	
	func reloadData(with date:Date){
		self.date = date
		
		for view in imageViews{
			view.removeFromSuperview()
		}
		imageViews = []
//		let formatter = DateFormatter()
//		formatter.dateFormat = "EEEE, MMM d, yyyy"
//		dateLabel.text = formatter.string(from: date)
//		dateLabel.sizeToFit()
		
		var index:Int = -1
		for i in 0..<ChartData.shared.clinicDataYearDates.count{
			if Calendar.current.isDate(ChartData.shared.clinicDataYearDates[i], inSameDayAs: date){
				index = i
			}
		}
		if(index == -1){ return; }
		let symptomValue = Int(ChartData.shared.allergyDataValues[index] * 3)
		let symptomString = SymptomRating(rawValue: symptomValue)?.asString() ?? ""
		myDataLabel.text = symptomValue == 0 ? symptomString + " today" : "my allergies were " + symptomString
		myDataLabel.sizeToFit()
		myAllergyFaceView.image = UIImage(named: "face\(symptomValue)")?.imageWithTint(Style.shared.colorFor(symptom: symptomValue))
		
		
		
//		let exposures = ChartData.shared.exposureDailyData[index]
		
//		print(exposures)
		
		
		func randomBool() -> Bool {
			return arc4random_uniform(6) == 0
		}

		var exposures:[Bool] = []
		for _ in 0..<5{
			exposures.append(randomBool())
		}
		
		var x:CGFloat = 0
		for i in 0..<exposures.count{
			if exposures[i] == true, let exposure = Exposures.init(rawValue: i){
				if let image = UIImage(named: exposure.asString()){
					let exposureView = UIImageView(image: image)
					exposureView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width*0.125, height: self.bounds.size.width*0.125)
					exposureView.center = CGPoint(x: self.bounds.size.width*0.5 + x * self.bounds.size.width*0.125, y: self.bounds.size.height*0.5)
					self.addSubview(exposureView)
					imageViews.append(exposureView)
				}
				x += 1
			}
		}
		
		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		
	}

}

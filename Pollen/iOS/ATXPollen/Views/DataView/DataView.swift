//
//  DataView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol DataViewDelegate {
	func showScheduleAlert()
	func showNeedNotificationsAlert()
}

class DataView: UIView, OverlayChartDelegate, MyAllergiesDelegate, AllergyQueryDelegate, ExposureQueryDelegate{
	
	var delegate:DataViewDelegate?

	let titleLabel = UILabel()
	let trackAllergiesButton = UIButton()
	let trackAllergiesBackground = UIImageView()

	let questionButton = UIBorderedButton()
	var currentAlert:PopAlertView?

	let segmentedControl = SegmentedControl(items: ["combined","by groups"])
	let overlayChartView = OverylayChartView()
	let pollenTypeChartView = PollenTypeChartView()
	let dailyDetailChartView = DailyDetailChartView()
	let myAllergiesView = MyAllergiesView()

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
		
		titleLabel.text = "my year in allergies"
		titleLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		titleLabel.textColor = .black
		
		trackAllergiesBackground.image = UIImage(named: "cutout")
		trackAllergiesButton.setTitle("begin tracking my allergies", for: .normal)
		trackAllergiesButton.setTitleColor(.black, for: .normal)
		trackAllergiesButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		trackAllergiesButton.sizeToFit()
		trackAllergiesButton.addTarget(self, action: #selector(openIntroScreen), for: .touchUpInside)

		questionButton.addTarget(self, action: #selector(openQuestion), for: .touchUpInside)

		overlayChartView.delegate = self
		myAllergiesView.delegate = self
		
		self.addSubview(overlayChartView)
		self.addSubview(pollenTypeChartView)
		self.addSubview(dailyDetailChartView)
		self.addSubview(myAllergiesView)

		self.addSubview(trackAllergiesBackground)
		self.addSubview(trackAllergiesButton)
		self.addSubview(segmentedControl)
		
		self.addSubview(titleLabel)
		
		segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
		
		PollenNotifications.shared.isLocalTimerRunning { (isRunning) in
			if isRunning{ self.showTrackButton = false }
			else{ self.showTrackButton = true }
		}

		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .chartDataDidUpdate, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .chartDataDidUpdate, object: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		titleLabel.sizeToFit()
		titleLabel.frame.origin = CGPoint(x: 20, y: -10)
		
		segmentedControl.center = CGPoint(x: self.bounds.size.width*0.5, y: 50)

		// my charts
		overlayChartView.frame = CGRect(x: 0, y: 80, width: self.bounds.size.width, height: self.bounds.size.height*0.55-80)
		pollenTypeChartView.frame = CGRect(x: 0, y: 80, width: self.bounds.size.width, height: self.bounds.size.height*0.55-80)
		
		dailyDetailChartView.frame = CGRect(x: 0, y: self.bounds.size.height*0.55, width: self.bounds.size.width, height: self.bounds.size.height*0.25)
		myAllergiesView.frame = CGRect(x: 0, y: self.bounds.size.height*0.8, width: self.bounds.size.width, height: self.bounds.size.height*0.2)

		pollenTypeChartView.isHidden = true

		trackAllergiesBackground.frame = CGRect(x: 0, y: self.bounds.size.height*0.75, width: self.bounds.size.width, height: self.bounds.size.height * 0.25)
//		trackAllergiesBackground.frame.origin.y += 40
//		if(Symptom.shared.entries.count > 0){ trackAllergiesBackground.isHidden = true }

		trackAllergiesButton.center = CGPoint(x: trackAllergiesBackground.center.x, y: trackAllergiesBackground.center.y)
		
		questionButton.setTitle("Allergies?", for: .normal)
		questionButton.sizeToFit()
		questionButton.frame = CGRect(x: 0, y: 0, width: questionButton.bounds.size.width+40, height: questionButton.bounds.size.height+15)
		questionButton.color = .black
		questionButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.93)
	}
	
	@objc func reloadData(){
		overlayChartView.reloadData()
		pollenTypeChartView.reloadData()
		var date = currentlyEditingDate
		if date == nil { date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) }
		dailyDetailChartView.reloadData(with: date!)
		myAllergiesView.reloadData(with: date!)

		PollenNotifications.shared.isLocalTimerRunning { (isRunning) in
			if isRunning{ self.showTrackButton = false }
			else{ self.showTrackButton = true }
		}
	}
	
	func didSelectDate(_ date: Date) {
		dailyDetailChartView.reloadData(with: date)
		myAllergiesView.reloadData(with: date)
	}
	
	var showTrackButton = true{
		didSet{
			if showTrackButton{
				self.trackAllergiesButton.isHidden = false
				self.trackAllergiesBackground.isHidden = false
			}
			else {
				self.trackAllergiesButton.isHidden = true
				self.trackAllergiesBackground.isHidden = true
			}
		}
	}
	
	@objc func openIntroScreen(){
		let introAllergyView = IntroAllergyTrackView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width*0.66, height: self.bounds.size.height*0.66))
		currentAlert = PopAlertView(title: "let's track!", view: introAllergyView)
		introAllergyView.getStartedButton.addTarget(self, action: #selector(openNextScreen), for: .touchUpInside)
		currentAlert!.show(animated: true)
	}

	@objc func openNextScreen(){
		PollenNotifications.shared.isLocalEnabled { (enabled) in
			if enabled{
				self.showTrackButton = false
				if let alert = self.currentAlert{
					alert.dismiss(animated: true)
				}
				self.delegate?.showScheduleAlert()
			}
			else {
				self.showTrackButton = true
				self.delegate?.showNeedNotificationsAlert()
			}
		}
//		let seasonsQuestionView = WhatSeasonsView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width*0.66, height: self.bounds.size.height*0.66))
//		currentAlert = PopAlertView(title: "1 / 2", view: seasonsQuestionView)
//		currentAlert!.show(animated: true)
	}
	
	@objc func segmentedControlDidChange(sender:UISegmentedControl){
		overlayChartView.isHidden = true
		pollenTypeChartView.isHidden = true

		switch sender.selectedSegmentIndex {
		case 0: overlayChartView.isHidden = false
		case 1: pollenTypeChartView.isHidden = false
		default: break;
		}
	}
	
	func allergyQueryDidChange(rating: SymptomRating?) {
		if let date = currentlyEditingDate{
			var currentSymptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).first
			if currentSymptom == nil { currentSymptom = SymptomEntry(date: date, location: nil, rating: nil, exposures: nil) }
			if var symptom = currentSymptom{
				symptom.rating = rating
				Symptom.shared.updateDatabaseWith(entry: symptom)
			}
		}
	}
	
	func exposureQueryDidChange(exposures: [Exposures]?) {
		if let date = currentlyEditingDate{
			var currentSymptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).first
			if currentSymptom == nil { currentSymptom = SymptomEntry(date: date, location: nil, rating: nil, exposures: nil) }
			if var symptom = currentSymptom{
				symptom.exposures = exposures
				Symptom.shared.updateDatabaseWith(entry: symptom)
			}
		}
	}
	
	@objc func openQuestion(){
		let alert = PopAlertView(title: "(1 / 2)", view: AllergyQueryView())
		alert.show(animated: true)
	}
	
	func updateSymptom(for date: Date) {
		currentlyEditingDate = date
		let smaller = (UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
		let allergyQueryView = AllergyQueryView(frame: CGRect(x: 0, y: 0, width: smaller*0.66, height: smaller*0.66))
		allergyQueryView.delegate = self
		if let dayIndex = ChartData.shared.yearlyIndex(for: date){
			if let symptomValue = ChartData.shared.allergyDataValues[dayIndex]{
				allergyQueryView.responseButtons[symptomValue].buttonState = .checked
			}
		}
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d, yyyy"
		let alert = PopAlertView(title: formatter.string(from: date), view: allergyQueryView)
		alert.show(animated: true)
	}
	
	var currentlyEditingDate:Date?
	
	func updateExposures(for date: Date) {
		currentlyEditingDate = date
		let smaller = (UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
		let exposureQueryView = ExposureQueryView(frame: CGRect(x: 0, y: 0, width: smaller*0.66, height: smaller*0.9))
		exposureQueryView.delegate = self
		if let dayIndex = ChartData.shared.yearlyIndex(for: date){
			ChartData.shared.exposureDailyData[dayIndex].enumerated().forEach { (i, element) in
				if element { exposureQueryView.responseButtons[i].buttonState = .checked }
			}
		}
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d, yyyy"
		let alert = PopAlertView(title: formatter.string(from: date), view: exposureQueryView)
		alert.show(animated: true)
	}
	
	func updateSymptomAndExposures(for date: Date) {
		currentlyEditingDate = date
		
//		let smaller = (UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
//		let allergyQueryView = AllergyQueryView(frame: CGRect(x: 0, y: 0, width: smaller*0.66, height: smaller*0.66))
//		allergyQueryView.responseButtons.forEach({
//			$0.addTarget(self, action: #selector(symptomQueryViewResponse), for: .touchUpInside)
//		})
//		if let dayIndex = ChartData.shared.yearlyIndex(for: date){
//			if let symptomValue = ChartData.shared.allergyDataValues[dayIndex]{
//				allergyQueryView.responseButtons[symptomValue].buttonState = .checked
//			}
//		}
//		let formatter = DateFormatter()
//		formatter.dateFormat = "EEEE, MMM d, yyyy"
//		let alert = PopAlertView(title: formatter.string(from: date), view: allergyQueryView)
//		alert.show(animated: true)
	}
	

}

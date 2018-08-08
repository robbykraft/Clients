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

class DataView: UIView, OverlayChartDelegate{
	
	var delegate:DataViewDelegate?
	let trackYourAllergiesButton = UIButton()
	let symptomsCoverView = UIImageView()
	let questionButton = UIBorderedButton()
	var currentAlert:PopAlertView?
	let segmentedControl = SegmentedControl(items: ["combined","by groups"])

	let overlayChartView = OverylayChartView()
	let pollenTypeChartView = PollenTypeChartView()
	
	let dailyDetailChartView = DailyDetailChartView()
	
	let titleLabel = UILabel()

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
		
		symptomsCoverView.image = UIImage(named: "cutout")

		trackYourAllergiesButton.setTitle("track my allergies", for: .normal)
		trackYourAllergiesButton.setTitleColor(.black, for: .normal)
		trackYourAllergiesButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		trackYourAllergiesButton.sizeToFit()
		trackYourAllergiesButton.addTarget(self, action: #selector(openIntroScreen), for: .touchUpInside)

		questionButton.addTarget(self, action: #selector(openQuestion), for: .touchUpInside)

		overlayChartView.delegate = self
		
		self.addSubview(overlayChartView)
		self.addSubview(pollenTypeChartView)
		self.addSubview(dailyDetailChartView)
		
		self.addSubview(symptomsCoverView)
		self.addSubview(trackYourAllergiesButton)
		self.addSubview(segmentedControl)
		
		self.addSubview(titleLabel)
		
		segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
		
		PollenNotifications.shared.isLocalEnabled { (enabled) in
			if enabled{ self.showTrackButton = false }
			else {      self.showTrackButton = true }
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
		overlayChartView.frame = CGRect(x: 0, y: 80, width: self.bounds.size.width, height: self.bounds.size.height*0.5-80)
		pollenTypeChartView.frame = CGRect(x: 0, y: 80, width: self.bounds.size.width, height: self.bounds.size.height*0.5-80)
		
		dailyDetailChartView.frame = CGRect(x: 0, y: self.bounds.size.height*0.5, width: self.bounds.size.width, height: self.bounds.size.height*0.5)

		///////////////////
		pollenTypeChartView.isHidden = true

		symptomsCoverView.frame = pollenTypeChartView.getSymptomChartsFrame()
		symptomsCoverView.frame.origin.y += 40
		if(Symptom.shared.entries.count > 0){ symptomsCoverView.isHidden = true }

		trackYourAllergiesButton.center = CGPoint(x: symptomsCoverView.center.x, y: symptomsCoverView.center.y)

		questionButton.setTitle("Allergies?", for: .normal)
		questionButton.sizeToFit()
		questionButton.frame = CGRect(x: 0, y: 0, width: questionButton.bounds.size.width+40, height: questionButton.bounds.size.height+15)
		questionButton.color = .black
		questionButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.93)
	}
	
	@objc func reloadData(){
		overlayChartView.reloadData()
		pollenTypeChartView.reloadData()
		dailyDetailChartView.reloadData(with: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
	}
	
	func didSelectDate(_ date: Date) {
		dailyDetailChartView.reloadData(with: date)
	}
	
	var showTrackButton = true{
		didSet{
			if showTrackButton{
				self.trackYourAllergiesButton.isHidden = false
				self.symptomsCoverView.isHidden = false
			}
			else {
				self.trackYourAllergiesButton.isHidden = true
				self.symptomsCoverView.isHidden = true
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
	
	@objc func openQuestion(){
		let alert = PopAlertView(title: "(1 / 2)", view: AllergyQueryView())
		alert.show(animated: true)
	}
	
}

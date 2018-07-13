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

class DataView: UIView{
	
	var delegate:DataViewDelegate?
	let trackYourAllergiesButton = UIButton()
	let symptomsCoverView = UIImageView()
	let questionButton = UIBorderedButton()
	var currentAlert:PopAlertView?
	let segmentedControl = SegmentedControl(items: ["Chart 1","Chart 2","Chart 3","Chart 4"])

	let overlayChartView = OverylayChartView()
	let pollenTypeChartView = PollenTypeChartView()
	let stackedChartView = StackedChartView()
	let monthlyBarChartView = MonthlyBarChartView()

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
		
		symptomsCoverView.image = UIImage(named: "cutout")

		trackYourAllergiesButton.setTitle("track my allergies", for: .normal)
		trackYourAllergiesButton.setTitleColor(.black, for: .normal)
		trackYourAllergiesButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		trackYourAllergiesButton.sizeToFit()
		trackYourAllergiesButton.addTarget(self, action: #selector(openIntroScreen), for: .touchUpInside)

		questionButton.addTarget(self, action: #selector(openQuestion), for: .touchUpInside)

		self.addSubview(overlayChartView)
		self.addSubview(pollenTypeChartView)
		self.addSubview(stackedChartView)
		self.addSubview(monthlyBarChartView)
		
		self.addSubview(symptomsCoverView)
		self.addSubview(trackYourAllergiesButton)
		self.addSubview(segmentedControl)
		
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
		
		segmentedControl.center = CGPoint(x: self.bounds.size.width*0.5, y: 20)

		// my charts
		overlayChartView.frame = CGRect(x: 0, y: 40, width: self.bounds.size.width, height: self.bounds.size.height-40)
		pollenTypeChartView.frame = CGRect(x: 0, y: 40, width: self.bounds.size.width, height: self.bounds.size.height-40)
		stackedChartView.frame = CGRect(x: 0, y: 40, width: self.bounds.size.width, height: self.bounds.size.height-40)
		monthlyBarChartView.frame = CGRect(x: 0, y: 40, width: self.bounds.size.width, height: self.bounds.size.height-40)

		///////////////////
		pollenTypeChartView.isHidden = true
		stackedChartView.isHidden = true
		monthlyBarChartView.isHidden = true

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
		stackedChartView.reloadData()
		monthlyBarChartView.reloadData()
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
		stackedChartView.isHidden = true
		monthlyBarChartView.isHidden = true

		switch sender.selectedSegmentIndex {
		case 0: overlayChartView.isHidden = false
		case 1: pollenTypeChartView.isHidden = false
		case 2: stackedChartView.isHidden = false
		case 3: monthlyBarChartView.isHidden = false
		default: break;
		}
	}
	
	@objc func openQuestion(){
		let alert = PopAlertView(title: "(1 / 2)", view: AllergyQueryView())
		alert.show(animated: true)
	}
	
}

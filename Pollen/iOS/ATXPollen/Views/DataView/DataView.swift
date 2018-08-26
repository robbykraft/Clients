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

class DataView: UIView, OverlayChartDelegate {
	
	var delegate:DataViewDelegate?
	
	var selectedDate:Date = Date()

	let trackAllergiesButton = UIButton()
	let trackAllergiesBackground = UIImageView()

	var currentAlert:PopAlertView?

	let segmentedControl = SegmentedControl(items: ["my allergies","pollen"])
	let overlayChartView = OverylayChartView()
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

		trackAllergiesBackground.image = UIImage(named: "cutout")
		trackAllergiesButton.setTitle("begin tracking my allergies", for: .normal)
		trackAllergiesButton.setTitleColor(.black, for: .normal)
		trackAllergiesButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		trackAllergiesButton.sizeToFit()
		trackAllergiesButton.addTarget(self, action: #selector(openIntroScreen), for: .touchUpInside)

		overlayChartView.delegate = self
		
		self.addSubview(overlayChartView)
		self.addSubview(dailyDetailChartView)
		self.addSubview(myAllergiesView)
		self.addSubview(trackAllergiesBackground)
		self.addSubview(trackAllergiesButton)
		self.addSubview(segmentedControl)
		
		segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
		
		PollenNotifications.shared.isLocalTimerRunning { (isRunning) in
			if isRunning{ self.showTrackButton = false }
			else{ self.showTrackButton = true }
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .chartDataDidUpdate, object: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		segmentedControl.center = CGPoint(x: self.bounds.size.width*0.5, y: 20)

		overlayChartView.frame = CGRect(x: 0, y: 50, width: self.bounds.size.width, height: self.bounds.size.height*0.55-50)
		dailyDetailChartView.frame = CGRect(x: 0, y: self.bounds.size.height*0.55, width: self.bounds.size.width, height: self.bounds.size.height*0.25)
		myAllergiesView.frame = CGRect(x: 0, y: self.bounds.size.height*0.8, width: self.bounds.size.width, height: self.bounds.size.height*0.2)

		trackAllergiesBackground.frame = CGRect(x: 0, y: self.bounds.size.height*0.8, width: self.bounds.size.width, height: self.bounds.size.height * 0.2)
		trackAllergiesButton.center = CGPoint(x: trackAllergiesBackground.center.x, y: trackAllergiesBackground.center.y)
	}
	
	@objc func reloadData(){
		overlayChartView.reloadData()

		dailyDetailChartView.reloadData(with: self.selectedDate)
		myAllergiesView.reloadData(with: self.selectedDate)

		PollenNotifications.shared.isLocalTimerRunning { (isRunning) in
			if isRunning{ self.showTrackButton = false }
			else{ self.showTrackButton = true }
		}

		self.layoutSubviews()
	}
	
	func didSelectDate(_ date: Date) {
		self.selectedDate = date
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
		currentAlert = PopAlertView(title: "let's track", view: introAllergyView)
		introAllergyView.getStartedButton.addTarget(self, action: #selector(trackingDidBegin), for: .touchUpInside)
		currentAlert!.show(animated: true)
	}

	@objc func trackingDidBegin(){
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
	}
	
	@objc func segmentedControlDidChange(sender:UISegmentedControl){
		switch overlayChartView.mode {
		case .combined: overlayChartView.mode = .groups
		case .groups: overlayChartView.mode = .combined
		}
	}
	
}

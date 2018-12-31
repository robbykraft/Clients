//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, HomeSlideViewDelegate, DataViewDelegate, AllergyQueryDelegate, ExposureQueryDelegate{
	
	let preferencesButton = UIButton()

	// everything on top: circle chart, bottom bar chart, blue circle
	let homeSlideView = HomeSlideView()
	// everything underneath: questions, map
	let dataView = DataView()
	
	var tooltip:UIView?
	var tooltipTimer:Timer?
	
	weak var popupView:PopAlertView? // pointer to current popup window if exists

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.delegate = self
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
						
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		let statusHeight:CGFloat = IS_IPHONE_X ? 0 : 22

		homeSlideView.frame = CGRect(x: 0, y: statusHeight, width: self.view.frame.size.width, height: self.view.frame.size.height-statusHeight)
		homeSlideView.slideViewDelegate = self
		
		let prefsImage = UIImage(named: "cogs") ?? UIImage()
		preferencesButton.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
		preferencesButton.setImage(prefsImage.imageWithTint(UIColor.white), for: .normal)
		preferencesButton.center = CGPoint.init(x: self.view.frame.size.width - 22-5, y: statusBarHeight()+5)
		preferencesButton.addTarget(self, action: #selector(preferencesButtonPressed), for: .touchUpInside)
		homeSlideView.addSubview(preferencesButton)
		
		dataView.delegate = self
		dataView.layer.anchorPoint = CGPoint(x:0.5, y:0.5)
		dataView.alpha = 0.0
		dataView.frame = CGRect(x: 0, y: 15 + 70, width: self.view.frame.size.width, height: self.view.frame.size.height - 15 - 70)

		self.view.addSubview(homeSlideView)
		self.view.addSubview(dataView)
		self.view.sendSubview(toBack:dataView)

		reloadData()
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .pollenDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .symptomDidUpdate, object: nil)
		NotificationCenter.default.addObserver(dataView, selector: #selector(reloadData), name: .chartDataDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(querySymptom(notification:)), name: .queryRequestSymptom, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(queryExposure(notification:)), name: .queryRequestExposure, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(querySymptomAndExposure(notification:)), name: .queryRequestSymptomAndExposure, object: nil)
		
		// tooltip and timer
		if !Pollen.shared.hasSeenCharts {
			tooltipTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(showToolTip), userInfo: nil, repeats: false)
		}

//		tooltipTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(showToolTip), userInfo: nil, repeats: false)

	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .pollenDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .symptomDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(dataView, name: .chartDataDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .queryRequestSymptom, object: nil)
		NotificationCenter.default.removeObserver(self, name: .queryRequestExposure, object: nil)
		NotificationCenter.default.removeObserver(self, name: .queryRequestSymptomAndExposure, object: nil)
	}
	
	@objc func reloadData(){
		homeSlideView.barChart.data = Array(ClinicData.shared.dailyCounts.prefix(15)).map({ $0.relevantToMyAllergies() })
		homeSlideView.radialChart.data = homeSlideView.barChart.data.first
		dataView.reloadData()
	}
		
	@objc func preferencesButtonPressed(){
		let nav = UINavigationController()
		nav.viewControllers = [Preferences.init(style: .grouped)]
		self.present(nav, animated: true, completion: nil)
	}
	
	func slideViewDidOpen(percent: CGFloat) {
		self.dataView.alpha = percent
		self.dataView.transform = CGAffineTransform.init(scaleX: percent*0.15+0.85, y: percent*0.15+0.85)
		
//		print("slide view did open")
		if !Pollen.shared.hasSeenCharts{
//			Pollen.shared.hasSeenChartsHint = true
			Pollen.shared.hasSeenCharts = true
			tooltipTimer?.invalidate()
			tooltipTimer = nil
		}
		if tooltip != nil{
			removeToolTip()
		}
	}
	
	@objc func showToolTip(){
		let scale = Style.shared.P18
		let toolTipView = UIView()
		toolTipView.frame = CGRect(x: 0, y: 0, width: scale*11, height: scale*4)
		toolTipView.backgroundColor = Style.shared.lightBlue
		let arrow = UIView()
		arrow.frame = CGRect(x: 0, y: 0, width: scale*1.5, height: scale*1.5)
		arrow.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		arrow.transform = CGAffineTransform(rotationAngle: 3.141592/4.0)
		arrow.backgroundColor = Style.shared.lightBlue
		arrow.center = CGPoint(x: scale*11*0.5, y: scale*4)
		toolTipView.addSubview(arrow)
		
		let label = UILabel()
		label.text = "Slide up for charts and data"
		label.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
		label.numberOfLines = 2
		label.frame.size.width = scale*9
		label.sizeToFit()
		label.textAlignment = .center
		label.center = CGPoint(x: scale*11*0.5, y: scale*4*0.5)
		label.textColor = .black
		toolTipView.addSubview(label)
		
		let button = UIButton(frame: toolTipView.bounds)
		button.addTarget(self, action: #selector(removeToolTip), for: .touchUpInside)
		toolTipView.addSubview(button)
		
		homeSlideView.addSubview(toolTipView)
		toolTipView.center = CGPoint(x: homeSlideView.touchTape.center.x,
									 y: homeSlideView.touchTape.center.y - scale*4*0.5 - scale*1.5)
		
		toolTipView.alpha = 0.0
		UIView.animate(withDuration: 0.3) {
			toolTipView.alpha = 1.0
		}
		tooltip = toolTipView
	}
	
	@objc func removeToolTip(){
		tooltip?.removeFromSuperview()
		tooltip = nil
	}
	
	func detailRequested(forSample sample: DailyPollenCount) {
//		let nav = UILightNavigationController()
		let nav = UINavigationController()
		let vc = PollenCountViewController()
		vc.data = sample
		nav.viewControllers = [vc]
		nav.modalPresentationStyle = .custom
		nav.modalTransitionStyle = .crossDissolve
		self.present(nav, animated: true, completion: nil)
	}
	
	// Query View Delegate
	func showScheduleAlert() {
		PollenNotifications.shared.enableLocalTimer(completionHandler: nil)
		let (hour, minute) = PollenNotifications.shared.getNotificationTime()
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a"
		let timeString = formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!)
		let alert = UIAlertController.init(title: "Setup Complete!", message: "Check your device at " + timeString + ", we'll ask how your allergies were that day.", preferredStyle: .alert)
		let action1 = UIAlertAction.init(title: "Got it", style: .cancel, handler:nil)
		alert.addAction(action1)
		self.present(alert, animated: true, completion: nil)
	}
	
	func showNeedNotificationsAlert(){
		let alert = UIAlertController.init(title: "Local Notifications need to be enabled", message: nil, preferredStyle: .alert)
		let action1 = UIAlertAction.init(title: "Okay", style: .cancel, handler:nil)
		alert.addAction(action1)
		self.present(alert, animated: true, completion: nil)
	}
	
	@objc func querySymptom(notification: NSNotification){
		let date = notification.userInfo?["date"] as? Date ?? Date()
		queryAllergies(date: date, symptoms: true, exposures: false)
	}
	@objc func queryExposure(notification: NSNotification){
		let date = notification.userInfo?["date"] as? Date ?? Date()
		queryAllergies(date: date, symptoms: false, exposures: true)
	}
	@objc func querySymptomAndExposure(notification: NSNotification){
		let date = notification.userInfo?["date"] as? Date ?? Date()
		queryAllergies(date: date, symptoms: true, exposures: true)
	}

	
	func queryAllergies(date: Date, symptoms: Bool, exposures: Bool) {
		if symptoms && !exposures{
			let popup = symptomPopup(for: date)
			popup.show(animated: true)
			self.popupView = popup
		}
		if exposures && !symptoms{
			let popup = exposurePopup(for: date)
			popup.show(animated: true)
			self.popupView = popup
		}
		if exposures && symptoms{
			let popup = symptomPopup(for: date)
			popup.show(animated: true)
			let queryView = popup.view as? AllergyQueryView
			queryView?.responseButtons.forEach { (button) in
				button.addTarget(self, action: #selector(dismissAllergiesAndOpenExposures), for: .touchUpInside)
			}
			self.popupView = popup
		}
	}
	
	@objc func dismissAllergiesAndOpenExposures(){
		if let popup = self.popupView{
			let queryView = popup.view as? AllergyQueryView
			if let date = queryView?.date{
				popup.dismiss(animated: true)
				let popup = exposurePopup(for: date)
				popup.show(animated: true)
				self.popupView = popup
			}
		}
	}

	
	func symptomPopup(for date:Date) -> PopAlertView{
		let size = UIScreen.main.bounds.size
		let smaller = (size.width < size.height) ? size.width : size.height
		let allergyQueryView = AllergyQueryView(frame: CGRect(x: 0, y: 0, width: smaller*0.66, height: smaller*0.66))
		allergyQueryView.delegate = self
		allergyQueryView.date = date
		if let symptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).first{
			if let value = symptom.rating?.rawValue{
				allergyQueryView.responseButtons[value].buttonState = .checked
			}
		}
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d, yyyy"
		return PopAlertView(title: formatter.string(from: date), view: allergyQueryView)
	}
	
	func exposurePopup(for date:Date) -> PopAlertView{
		let size = UIScreen.main.bounds.size
		let smaller = (size.width < size.height) ? size.width : size.height
		let exposureQueryView = ExposureQueryView(frame: CGRect(x: 0, y: 0, width: smaller*0.66, height: smaller*0.9))
		exposureQueryView.delegate = self
		exposureQueryView.date = date
		let exposureTypes:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})
		if let symptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).first{
			if let exposures = symptom.exposures{
				exposures.enumerated().forEach({
					let index = exposureTypes.index(of: $0.element)!
					exposureQueryView.responseButtons[index].buttonState = .checked
				})
			}
		}
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d, yyyy"
		return PopAlertView(title: formatter.string(from: date), view: exposureQueryView)
	}

	func allergyQueryDidChange(rating: SymptomRating?, date:Date?) {
		if let d = date{
			var currentSymptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: d) }).first
			if currentSymptom == nil { currentSymptom = SymptomEntry(date: d, location: nil, rating: nil, exposures: nil) }
			if var symptom = currentSymptom{
				symptom.rating = rating
				Symptom.shared.updateDatabaseWith(entry: symptom)
			}
		}
	}
	
	func exposureQueryDidChange(exposures: [Exposures]?, date:Date?) {
		if let d = date{
			var currentSymptom = Symptom.shared.entries.filter({ Calendar.current.isDate($0.date, inSameDayAs: d) }).first
			if currentSymptom == nil { currentSymptom = SymptomEntry(date: d, location: nil, rating: nil, exposures: nil) }
			if var symptom = currentSymptom{
				symptom.exposures = exposures
				Symptom.shared.updateDatabaseWith(entry: symptom)
			}
		}
	}
}

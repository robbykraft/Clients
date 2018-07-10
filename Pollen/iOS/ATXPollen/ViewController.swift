//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, HomeSlideViewDelegate, DataViewDelegate{
	
	let preferencesButton = UIButton()

	// everything on top: circle chart, bottom bar chart, blue circle
	let homeSlideView = HomeSlideView()
	// everything underneath: questions, map
	let dataView = DataView()

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

		homeSlideView.frame = CGRect(x: 0, y: 22, width: self.view.frame.size.width, height: self.view.frame.size.height-22)
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

//		PollenNotifications.shared.enableLocalTimer()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .pollenDidUpdate, object: nil)
	}
	
	@objc func reloadData(){
		homeSlideView.barChart.data = Array(ClinicData.shared.dailyCounts.prefix(15)).map({ $0.relevantToMyAllergies() })
		homeSlideView.radialChart.data = homeSlideView.barChart.data.first
		dataView.reloadData()
		dataView.layoutSubviews()
	}
		
	@objc func preferencesButtonPressed(){
		let nav = UINavigationController()
		nav.viewControllers = [Preferences.init(style: .grouped)]
		self.present(nav, animated: true, completion: nil)
	}
	
	func slideViewDidOpen(percent: CGFloat) {
		self.dataView.alpha = percent
		self.dataView.transform = CGAffineTransform.init(scaleX: percent*0.15+0.85, y: percent*0.15+0.85)
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
		let alert = UIAlertController.init(title: "At the close of each day we'll send you a notification asking how were your allergies.", message: nil, preferredStyle: .alert)
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

}

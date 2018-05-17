//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, QueryViewDelegate, HomeSlideViewDelegate{
	
	let preferencesButton = UIButton()

	// everything on top: circle chart, bottom bar chart, blue circle
	let homeSlideView = HomeSlideView()
	// everything underneath: questions, map
	let queryView = QueryView()

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
		
		queryView.layer.anchorPoint = CGPoint(x:0.5, y:0.5)
		queryView.alpha = 0.0
		queryView.delegate = self
		queryView.frame = CGRect(x: 0, y: 15 + 70, width: self.view.frame.size.width, height: self.view.frame.size.height - 15 - 70)

		self.view.addSubview(homeSlideView)
		self.view.addSubview(queryView)
		self.view.sendSubview(toBack:queryView)

		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .pollenDidUpdate, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .pollenDidUpdate, object: nil)
	}
	
	@objc func reloadData(){
		let sortedSamples = Array(Data.shared.pollenSamples.values).sorted { (a, b) -> Bool in
			if let aDate = a.date, let bDate = b.date{
				return aDate > bDate
			}
			return false
		}
		if let mostRecent = sortedSamples.first{
			homeSlideView.radialChart.data = mostRecent
		}
		homeSlideView.barChart.data = sortedSamples
	}
	
	func queryViewDateDidChange(date:Date){
		homeSlideView.updateTopSectionDate(closestMatch: date)
	}
	
	@objc func preferencesButtonPressed(){
		let nav = UINavigationController()
		nav.viewControllers = [Preferences.init(style: .grouped)]
		self.present(nav, animated: true, completion: nil)
	}
	
	func slideViewDidOpen(percent: CGFloat) {
		self.queryView.alpha = percent
		self.queryView.transform = CGAffineTransform.init(scaleX: percent*0.15+0.85, y: percent*0.15+0.85)
	}
	
	func detailRequested(forSample sample: PollenSample) {
//		let nav = UILightNavigationController()
		let nav = UINavigationController()
		let vc = PollenCountViewController()
		vc.data = sample
		nav.viewControllers = [vc]
		nav.modalPresentationStyle = .custom
		nav.modalTransitionStyle = .crossDissolve
		self.present(nav, animated: true, completion: nil)
	}

}

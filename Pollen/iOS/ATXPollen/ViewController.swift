//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UINavigationControllerDelegate, QueryViewDelegate, UIScrollViewDelegate, HomeSlideViewDelegate{
	
	let preferencesButton = UIButton()

	// home slide view contains everything on the top layer: circle chart, bottom bar chart, blue circle
	let homeSlideView = HomeSlideView()
	// query view contains everything below, after the user pulls back the blue circle
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
		homeSlideView.delegate = self
		
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
//		queryView.frame = CGRect(x: 0, y: barChartTop + 15, width: self.view.frame.size.width, height: self.scrollView.contentSize.height - barChartTop - 15)

		self.view.addSubview(homeSlideView)
		self.view.addSubview(queryView)
		self.view.sendSubview(toBack:queryView)
		
		let mapView = MKMapView()
		mapView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
		self.view.addSubview(mapView)
		
		
//		if UIDevice().userInterfaceIdiom == .phone {
//			if UIScreen.main.nativeBounds.height == 2436{
//				self.view.backgroundColor = Style.shared.blue
//			}
//			switch UIScreen.main.nativeBounds.height {
//			case 1136:
//				print("iPhone 5 or 5S or 5C")
//			case 1334:
//				print("iPhone 6/6S/7/8")
//			case 2208:
//				print("iPhone 6+/6S+/7+/8+")
//			case 2436:
//				self.view.backgroundColor = UIColor.white
//			default:
//				print("unknown")
//			}
//		}
	
	}
//
//	func downloadAndRefresh(){
//		Pollen.shared.loadRecentData(numberOfDays: 1) { (sample) in
//			self.radialChart.data = sample
//			self.refreshBarChart()
//		}
//		self.samples = []
//		Pollen.shared.loadRecentData(numberOfDays: 15) { (sample) in
//			self.samples.append(sample)
//			self.refreshBarChart()
//		}
//	}
	
	
	func queryViewDateDidChange(date:Date){
		homeSlideView.updateTopSectionDate(closestMatch: date)
	}
	
	@objc func preferencesButtonPressed(){
//		let nav = UINavigationController()
//		nav.viewControllers = [Preferences.init(style: .grouped)]
//		self.present(nav, animated: true, completion: nil)
	}
	
	
	func slideViewDidOpen(percent: CGFloat) {
		self.queryView.alpha = percent
		self.queryView.transform = CGAffineTransform.init(scaleX: percent*0.15+0.85, y: percent*0.15+0.85)
		if percent >= 1.0 {
//			if UserDefaults.standard.bool(forKey: "welcomeScreenHasSeen") == false{
//				print("synchronizing welcome screen has been seen")
//				UserDefaults.standard.set(true, forKey: "welcomeScreenHasSeen")
//				UserDefaults.standard.synchronize()
//			}
		}
	}
	
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		homeSlideView.scrollViewDidScroll(homeSlideView)
	}

}

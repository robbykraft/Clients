//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import Firebase

//class ViewController: UIViewController, UINavigationControllerDelegate {
//	func downloadAndRefresh(){}

class ViewController: UIViewController, UINavigationControllerDelegate, BarChartDelegate, UIScrollViewDelegate, QueryViewDelegate{

	let scrollView = MainScrollView()

	var radialChart = UIRadialChart()
	var barChart = UIBarChartView()
	var radialChartOrigin = CGPoint.zero

	let preferencesButton = UIButton()
	let radialButton = UIButton()

	var samples:[Sample] = []

	let queryView = QueryView()

	var barChartCenter:CGPoint = .zero
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.delegate = self
		
		radialChart.refreshViewData()
		self.refreshBarChart()
		self.radialChart.center = radialChartOrigin
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
				
		let statusBarHeight:CGFloat = 22
		var barChartTop:CGFloat = self.view.frame.size.height - 200
		var radius:CGFloat = self.view.frame.size.height * 1.25
		var circleCenter = CGPoint(x: self.view.center.x, y: barChartTop - radius)
		
		if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			// iphone x
			barChartTop = self.view.frame.size.height - 230
			radius = self.view.frame.size.height * 1
			circleCenter = CGPoint(x: self.view.center.x, y: barChartTop - radius)
		}

		
		self.scrollView.frame = CGRect(x: 0, y: 22, width: self.view.frame.size.width, height: self.view.frame.size.height-22)
		self.scrollView.delegate = self
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + barChartTop - 80)
		if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			// iphone x
			self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + barChartTop - 80 - 80)
		}

		self.scrollView.showsVerticalScrollIndicator = false
		self.scrollView.isPagingEnabled = true
		self.scrollView.delaysContentTouches = false
		self.view.addSubview(self.scrollView)
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.scrollView.backgroundColor = UIColor.clear
		if UIDevice().userInterfaceIdiom == .phone {
			if UIScreen.main.nativeBounds.height == 2436{
				self.view.backgroundColor = Style.shared.blue
			}
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
		}

		
		let layer = CAShapeLayer()
		let circle = UIBezierPath.init(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		layer.path = circle.cgPath
		layer.fillColor = Style.shared.blue.cgColor
//		layer.fillColor = Style.shared.lightBlue.cgColor
//		layer.lineWidth = 10
//		layer.strokeColor = Style.shared.blue.cgColor
		self.scrollView.layer.addSublayer(layer)
		
		// attribution text
//		let image = self.makeCurvedAttributionText(size: CGSize.init(width: radius*2, height: radius*2), textRadius: radius-Style.shared.P18)
//		let radialLabelImageView:UIImageView = UIImageView(image: image)
//		radialLabelImageView.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
//		self.scrollView.addSubview(radialLabelImageView)
//		radialLabelImageView.center = circleCenter
		
		if(IS_IPAD){
			radialChart = UIRadialChart.init(frame:
				CGRect.init(x: self.view.frame.size.width*0.05,
				            y: statusBarHeight+self.view.frame.size.width*0.05,
				            width: self.view.frame.size.width*0.9,
				            height: self.view.frame.size.width * 0.9))
			radialChartOrigin = CGPoint(x: self.view.bounds.size.width*0.5, y: statusBarHeight + self.view.frame.size.width*0.5 )

		} else if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			radialChart = UIRadialChart.init(frame: CGRect.init(x: 0, y: statusBarHeight + (self.view.frame.size.height - 320.0) * 0.22, width: self.view.frame.size.width, height: self.view.frame.size.width))
			radialChartOrigin = CGPoint(x: self.view.bounds.size.width*0.5, y: statusBarHeight + (self.view.frame.size.width - 320.0) * 0.8 + self.view.frame.size.width*0.5 )
		
		}
		else{
			radialChart = UIRadialChart.init(frame: CGRect.init(x: 0, y: statusBarHeight + (self.view.frame.size.height - 320.0) * 0.13, width: self.view.frame.size.width, height: self.view.frame.size.width))
			radialChartOrigin = CGPoint(x: self.view.bounds.size.width*0.5, y: statusBarHeight + (self.view.frame.size.width - 320.0) * 0.4 + self.view.frame.size.width*0.5 )
		
		}
		self.scrollView.addSubview(radialChart)


		barChart = UIBarChartView.init(frame: CGRect.init(x: 0, y: barChartTop, width: self.view.frame.size.width, height: 200))
		barChart.delegate = self
		self.scrollView.addSubview(barChart)
		self.barChartCenter = barChart.center
		
		radialButton.frame = CGRect.init(x: 0, y: 0, width: radialChart.frame.size.width*0.66, height: radialChart.frame.size.height*0.66)
		radialButton.center = radialChart.center
		radialButton.backgroundColor = UIColor.clear
		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchCancel)
		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchDragExit)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDragEnter)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDown)
		radialButton.addTarget(self, action: #selector(radialTouchUpInside), for: .touchUpInside)
		self.scrollView.addSubview(radialButton)
		
		preferencesButton.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
		preferencesButton.setImage(UIImage.init(named: "cogs")?.imageWithTint(UIColor.white), for: .normal)
		preferencesButton.center = CGPoint.init(x: self.view.frame.size.width - 22-5, y: statusBarHeight+5)
		preferencesButton.addTarget(self, action: #selector(preferencesButtonPressed), for: .touchUpInside)
		self.scrollView.addSubview(preferencesButton)
		
		queryView.layer.anchorPoint = CGPoint(x:0.5, y:0.5)
		queryView.alpha = 0.0
		queryView.delegate = self
		queryView.frame = CGRect(x: 0, y: 15 + 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 15 - 100)
//		queryView.frame = CGRect(x: 0, y: barChartTop + 15, width: self.view.frame.size.width, height: self.scrollView.contentSize.height - barChartTop - 15)
		self.view.addSubview(queryView)
		self.view.sendSubview(toBack:queryView)
		
		// SET QUERY VIEW WELCOME SCREEN
//		welcomeViewIntroScreen()

		///////////////
		
//		self.scrollView.isScrollEnabled = false
		
		
		let touchTapeBack = UIView()
		touchTapeBack.backgroundColor = Style.shared.blue
		touchTapeBack.frame = CGRect(x:self.view.center.x-25, y:barChartTop - 30-10, width:50, height:3*8+20)
		self.scrollView.addSubview(touchTapeBack)
		
		for i in 0..<3{
			let touchTape = UIView()
			touchTape.layer.cornerRadius = 2
			touchTape.frame = CGRect(x: 0, y: 0, width: 36, height: 4)
			touchTape.center = CGPoint(x: self.view.center.x, y: barChartTop + CGFloat(i)*8 - 30)
			touchTape.clipsToBounds = true
			touchTape.layer.backgroundColor = UIColor.white.cgColor
			self.scrollView.addSubview(touchTape)
		}
		
	}
	
	func downloadAndRefresh(){
		Pollen.shared.loadRecentData(numberOfDays: 1) { (sample) in
			self.radialChart.data = sample
			self.refreshBarChart()
		}
		self.samples = []
		Pollen.shared.loadRecentData(numberOfDays: 15) { (sample) in
			self.samples.append(sample)
			self.refreshBarChart()
		}
	}
	
	func refreshBarChart(){
		// build bar chart again
		var barValues:[Float] = []
		for sample in self.samples{
//			let keys = Array(sample.values.keys)
			let reports = sample.report()
			var dailyHigh:Float = 0.0
			for i in 0..<reports.count{
				let (_, _, logValue, _) = reports[i]
				if logValue > dailyHigh{
					dailyHigh = logValue
				}
			}
			barValues.append( dailyHigh )
		}
		self.barChart.values = barValues
		// set bar labels
		var dateStrings:[String] = []
		for sample in self.samples{
			if let date = sample.date{
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "EEEEE"
				dateStrings.append(dateFormatter.string(from: date).localizedUppercase)
			}
		}
		self.barChart.labels = dateStrings
	}
	
	func queryViewDateDidChange(date:Date){
		self.updateTopSectionDate(closestMatch: date)
	}
	
	func updateTopSectionDate(closestMatch:Date){
		var closestI = 0
		for i in 1..<self.samples.count{
			let dDate = abs(closestMatch.timeIntervalSince1970 - (self.samples[i].date?.timeIntervalSince1970)!)
			let closestSoFar = abs(closestMatch.timeIntervalSince1970 - (self.samples[closestI].date?.timeIntervalSince1970)!)
			if dDate < closestSoFar{
				closestI = i
			}
		}
		// this calls the delegate back to here, barChartDidUpdateSelection
		self.barChart.didTouchIn(number: closestI)
		
	}
	
	func barChartDidUpdateSelection(sender: UIBarChartView) {
		let selected = sender.selected
		if selected < self.samples.count{
			self.radialChart.data = self.samples[selected]
		}
	}
	
	@objc func preferencesButtonPressed(){
		let nav = UINavigationController()
		nav.viewControllers = [Preferences.init(style: .grouped)]
		self.present(nav, animated: true, completion: nil)
	}
	
	@objc func radialTouchDown(){
		radialChart.pressed = true
	}
	
	@objc func radialTouchCancel(){
		radialChart.pressed = false
	}

	@objc func radialTouchUpInside(){
		radialChart.pressed = false
		if samples.count > 0{
			let nav = UILightNavigationController()
			let vc = DetailTableViewController()
			vc.data = self.radialChart.data
			nav.viewControllers = [vc]
			nav.modalPresentationStyle = .custom
			nav.modalTransitionStyle = .crossDissolve
			self.present(nav, animated: true, completion: nil)
		}
	}
	
	/////////////// SCROLL VIEW ///////////////////
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		var pct = scrollView.contentOffset.y / (scrollView.contentSize.height - self.view.bounds.height)
		if pct < 0.0 { pct = 0.0}
		if pct > 1.0 { pct = 1.0}
		self.radialChart.center = CGPoint(x: radialChartOrigin.x, y: radialChartOrigin.y - pct * 100)
		self.barChart.center = CGPoint(x:self.barChartCenter.x, y:self.barChartCenter.y + pct*self.view.frame.size.height)
		self.queryView.alpha = pct
		self.queryView.transform = CGAffineTransform.init(scaleX: pct*0.15+0.85, y: pct*0.15+0.85)
		if pct >= 1.0 {
			if UserDefaults.standard.bool(forKey: "welcomeScreenHasSeen") == false{
				print("synchronizing welcome screen has been seen")
				UserDefaults.standard.set(true, forKey: "welcomeScreenHasSeen")
				UserDefaults.standard.synchronize()
			}
		}
	}

	

}

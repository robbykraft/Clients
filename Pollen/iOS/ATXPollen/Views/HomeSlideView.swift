//
//  HomeSlideView.swift
//  Allergy
//
//  Created by Robby on 10/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol HomeSlideViewDelegate {
	func slideViewDidOpen(percent:CGFloat)
}

class HomeSlideView: UIScrollView, BarChartDelegate, UIScrollViewDelegate {
	
	var slideViewDelegate:HomeSlideViewDelegate?

	var radialChart = UIRadialChart()
	var barChart = UIBarChartView()
	let radialButton = UIButton()
	let sliderLayer = CALayer()
	let touchTape = UIView()

	var radialChartCenter = CGPoint.zero
	var barChartCenter:CGPoint = CGPoint.zero

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
	
	override var frame: CGRect{
		didSet{
			setupSubviews()
		}
	}
	
	func initUI(){
		
		self.delegate = self
		
		self.showsVerticalScrollIndicator = false
		self.isPagingEnabled = true
		self.delaysContentTouches = false
		self.backgroundColor = UIColor.clear

		barChart.delegate = self
		
		radialButton.center = radialChart.center
		radialButton.backgroundColor = UIColor.clear
//		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchCancel)
//		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchDragExit)
//		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDragEnter)
//		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDown)
//		radialButton.addTarget(self, action: #selector(radialTouchUpInside), for: .touchUpInside)
		
		touchTape.backgroundColor = Style.shared.blue

		self.layer.addSublayer(sliderLayer)
		self.addSubview(touchTape)
		self.addSubview(radialChart)
		self.addSubview(barChart)
		self.addSubview(radialButton)
		
		NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .pollenDidUpdate, object: nil)
	}
	
	deinit{
		NotificationCenter.default.removeObserver(self, name: .pollenDidUpdate, object: nil)
	}
	
	func setupSubviews() {
		print("home slide view layout subviews")

		let statusBarHeight:CGFloat = 22
		var barChartTop:CGFloat = self.frame.size.height - 200
		var radius:CGFloat = self.frame.size.height * 1.25
		var circleCenter = CGPoint(x: self.center.x, y: barChartTop - radius)
		if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			// iphone x
			barChartTop = self.frame.size.height - 230
			radius = self.frame.size.height * 1
			circleCenter = CGPoint(x: self.center.x, y: barChartTop - radius)
		}

		self.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height + barChartTop - 80)
		if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			// iphone x
			self.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height + barChartTop - 80 - 80)
		}

		sliderLayer.sublayers = []
		let layer = CAShapeLayer()
		let circle = UIBezierPath.init(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		layer.path = circle.cgPath
		layer.fillColor = Style.shared.blue.cgColor
		sliderLayer.addSublayer(layer)

		barChart.frame = CGRect.init(x: 0, y: barChartTop, width: self.frame.size.width, height: 200)

		if(IS_IPAD){
			radialChart.frame = CGRect(x: self.frame.size.width*0.05,
									   y: statusBarHeight+self.frame.size.width*0.05,
									   width: self.frame.size.width*0.9,
									   height: self.frame.size.width * 0.9)
			radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + self.frame.size.width*0.5 )
			
		} else if( UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 ){
			radialChart.frame = CGRect(x: 0, y: statusBarHeight + (self.frame.size.height - 320.0) * 0.22, width: self.frame.size.width, height: self.frame.size.width)
			radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + (self.frame.size.width - 320.0) * 0.8 + self.frame.size.width*0.5 )
			
		}
		else{
			radialChart.frame = CGRect(x: 0, y: statusBarHeight + (self.frame.size.height - 320.0) * 0.13, width: self.frame.size.width, height: self.frame.size.width)
			radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + (self.frame.size.width - 320.0) * 0.4 + self.frame.size.width*0.5 )
		}
		
		barChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: barChartTop + 100)

		radialButton.frame = CGRect.init(x: 0, y: 0, width: radialChart.frame.size.width*0.66, height: radialChart.frame.size.height*0.66)
		
		radialChart.center = radialChartCenter
		barChart.center = barChartCenter

		touchTape.frame = CGRect(x:self.center.x-25, y:barChartTop - 30-10, width:50, height:3*8+20)
		for view in touchTape.subviews{
			view.removeFromSuperview()
		}
		for i in 0..<3{
			let touchTapeLine = UIView()
			touchTapeLine.layer.cornerRadius = 2
			touchTapeLine.frame = CGRect(x: 0, y: 0, width: 36, height: 4)
			touchTapeLine.center = CGPoint(x: touchTape.frame.size.width*0.5, y: touchTape.frame.size.height*0.5 + CGFloat(i-1)*8)
			touchTapeLine.clipsToBounds = true
			touchTapeLine.layer.backgroundColor = UIColor.white.cgColor
			touchTape.addSubview(touchTapeLine)
		}
		
		radialChart.refreshViewData()
		self.refreshBarChart()
	}
	
	@objc func refreshData(){
		
		let samples = Data.shared.pollenSamples.sorted { (a, b) -> Bool in
			if let aDate = a.date, let bDate = b.date{
				return aDate > bDate
			}
			return false
		}
		if let mostRecent = samples.first{
			radialChart.data = mostRecent
			radialChart.refreshViewData()
		}
		refreshBarChart()
	}
	
	func refreshBarChart(){
		// build bar chart again
		var barValues:[Float] = []
		let samples = Data.shared.pollenSamples.sorted { (a, b) -> Bool in
			if let aDate = a.date, let bDate = b.date{
				return aDate > bDate
			}
			return false
		}
		for sample in samples{
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
		for sample in samples{
			if let date = sample.date{
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "EEEEE"
				dateStrings.append(dateFormatter.string(from: date).localizedUppercase)
			}
		}
		self.barChart.labels = dateStrings
	}

	func updateTopSectionDate(closestMatch:Date){
//		var closestI = 0
//		for i in 1..<self.samples.count{
//			let dDate = abs(closestMatch.timeIntervalSince1970 - (self.samples[i].date?.timeIntervalSince1970)!)
//			let closestSoFar = abs(closestMatch.timeIntervalSince1970 - (self.samples[closestI].date?.timeIntervalSince1970)!)
//			if dDate < closestSoFar{
//				closestI = i
//			}
//		}
////		 this calls the delegate back to here, barChartDidUpdateSelection
//		self.barChart.didTouchIn(number: closestI)
		
	}
	
	func barChartDidUpdateSelection(sender: UIBarChartView) {
//		let selected = sender.selected
//		if selected < self.samples.count{
//			self.radialChart.data = self.samples[selected]
//		}
	}
	@objc func radialTouchDown(){
		radialChart.pressed = true
	}
	
	@objc func radialTouchCancel(){
		radialChart.pressed = false
	}
	
	@objc func radialTouchUpInside(){
		radialChart.pressed = false
//		if samples.count > 0{
//			let nav = UILightNavigationController()
//			let vc = DetailTableViewController()
//			vc.data = self.radialChart.data
//			nav.viewControllers = [vc]
//			nav.modalPresentationStyle = .custom
//			nav.modalTransitionStyle = .crossDissolve
//			self.present(nav, animated: true, completion: nil)
//		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		var pct = scrollView.contentOffset.y / (scrollView.contentSize.height - self.bounds.height)
		if pct < 0.0 { pct = 0.0}
		if pct > 1.0 { pct = 1.0}
		radialChart.center = CGPoint(x: radialChartCenter.x, y: radialChartCenter.y - pct * 100)
		barChart.center = CGPoint(x:barChartCenter.x, y:barChartCenter.y + pct*self.frame.size.height)
		slideViewDelegate?.slideViewDidOpen(percent: pct)
	}

	override func touchesShouldCancel(in view: UIView) -> Bool {
		return true
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		return self.subviews
			.map { (view) -> Bool in
				return view.frame.contains(point)
//				return view.point(inside: point, with: event)
			}
			.reduce(false, { $0 || $1 })
	}

}

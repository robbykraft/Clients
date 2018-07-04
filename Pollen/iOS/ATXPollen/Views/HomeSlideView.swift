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
	func detailRequested(forSample sample:DailyPollenCount)
}

class HomeSlideView: UIScrollView, BarChartDelegate, UIScrollViewDelegate {
	
	var slideViewDelegate:HomeSlideViewDelegate?

	var radialChart = UIRadialChart()
	var barChart = UIBarChartView()
	let radialButton = UIButton()
	let sliderLayer = CALayer()
	let touchTape = UIView()

	var radialChartCenter = CGPoint.zero
	var barChartCenter = CGPoint.zero

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
		touchTape.backgroundColor = Style.shared.blue

		self.layer.addSublayer(sliderLayer)
		self.addSubview(touchTape)
		self.addSubview(radialChart)
		self.addSubview(barChart)
		self.addSubview(radialButton)

		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchCancel)
		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchDragExit)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDragEnter)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDown)
		radialButton.addTarget(self, action: #selector(radialTouchUpInside), for: .touchUpInside)
	}

	func setupSubviews() {

		let statusBarHeight:CGFloat = 0
		let barChartTop:CGFloat = IS_IPHONE_X ? self.frame.size.height - 230 : self.frame.size.height - 200
		let circleRadius:CGFloat = IS_IPHONE_X ? self.frame.size.height : self.frame.size.height * 1.25
		let circleCenter = CGPoint(x: self.center.x, y: barChartTop - circleRadius)

		let backgroundCircle = CAShapeLayer()
		backgroundCircle.path = UIBezierPath.init(arcCenter: circleCenter, radius: circleRadius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
		backgroundCircle.fillColor = Style.shared.blue.cgColor
		sliderLayer.sublayers = [backgroundCircle]

		radialChart.frame = CGRect(x: 0, y: statusBarHeight + (self.frame.size.height - 320.0) * 0.13, width: self.frame.size.width, height: self.frame.size.width)
		radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + (self.frame.size.width - 320.0) * 0.4 + self.frame.size.width*0.5 )
		
		if(IS_IPAD){
			radialChart.frame = CGRect(x: self.frame.size.width*0.05,
									   y: statusBarHeight+self.frame.size.width*0.05,
									   width: self.frame.size.width*0.9,
									   height: self.frame.size.width * 0.9)
			radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + self.frame.size.width*0.5 )
		} else if(IS_IPHONE_X){
			radialChart.frame = CGRect(x: 0, y: statusBarHeight + (self.frame.size.height - 320.0) * 0.22, width: self.frame.size.width, height: self.frame.size.width)
			radialChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: statusBarHeight + (self.frame.size.width - 320.0) * 0.8 + self.frame.size.width*0.5 )
		}
		
		barChart.frame = CGRect.init(x: 0, y: barChartTop, width: self.frame.size.width, height: 200)
		barChartCenter = CGPoint(x: self.bounds.size.width*0.5, y: barChartTop + 100)

		radialButton.frame = CGRect.init(x: 0, y: 0, width: radialChart.frame.size.width*0.66, height: radialChart.frame.size.height*0.66)
		
		radialChart.center = radialChartCenter
		barChart.center = barChartCenter

		touchTape.frame = CGRect(x:self.center.x-25, y:barChartTop - 30-10, width:50, height:3*8+20)
		touchTape.subviews.forEach{ $0.removeFromSuperview() }
		for i in 0..<3{
			let touchTapeLine = UIView()
			touchTapeLine.layer.cornerRadius = 2
			touchTapeLine.frame = CGRect(x: 0, y: 0, width: 36, height: 4)
			touchTapeLine.center = CGPoint(x: touchTape.frame.size.width*0.5, y: touchTape.frame.size.height*0.5 + CGFloat(i-1)*8)
			touchTapeLine.clipsToBounds = true
			touchTapeLine.layer.backgroundColor = UIColor.white.cgColor
			touchTape.addSubview(touchTapeLine)
		}
		
		
		self.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height + barChartTop - 44)
		if(IS_IPHONE_X){
			self.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height + barChartTop - 80 - 80 + 22)
		}
	}

	// UIBarChartView delegate
	func barChartDidUpdateSelection(pollenSample: DailyPollenCount) {
		self.radialChart.data = pollenSample
	}
	
	@objc func radialTouchDown(){
		radialChart.pressed = true
	}
	
	@objc func radialTouchCancel(){
		radialChart.pressed = false
	}
	
	@objc func radialTouchUpInside(){
		radialChart.pressed = false
		if let sample = self.radialChart.data{
			self.slideViewDelegate?.detailRequested(forSample: sample)
		}
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

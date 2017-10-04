//
//  ViewController.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate, BarChartDelegate, UIScrollViewDelegate{
	
	let scrollView = UIScrollView()
	
	var radialChart = UIRadialChart()
	var barChart = UIBarChartView()
	var radialChartOrigin = CGPoint.zero
	
	let preferencesButton = UIButton()
	let radialButton = UIButton()
	
	var samples:[Sample] = []
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.delegate = self
		
		radialChart.refreshViewData()
		self.refreshBarChart()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let statusBarHeight:CGFloat = 0//22
		let barChartTop:CGFloat = self.view.frame.size.height - 200
		let radius:CGFloat = self.view.frame.size.height * 1.25
		let circleCenter = CGPoint.init(x: self.view.center.x, y: barChartTop - radius)
		
		self.scrollView.frame = self.view.bounds
		self.scrollView.delegate = self
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + barChartTop - 80)
		self.scrollView.isPagingEnabled = true
		self.view = self.scrollView
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		
		let layer = CAShapeLayer()
		let circle = UIBezierPath.init(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		layer.path = circle.cgPath
		layer.fillColor = Style.shared.blue.cgColor
//		layer.fillColor = Style.shared.lightBlue.cgColor
//		layer.lineWidth = 10
//		layer.strokeColor = Style.shared.blue.cgColor
		self.view.layer.addSublayer(layer)
		
		let image = self.makeCurvedAttributionText(size: CGSize.init(width: radius*2, height: radius*2), textRadius: radius-Style.shared.P18)
		let radialLabelImageView:UIImageView = UIImageView(image: image)
		radialLabelImageView.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
		self.view.addSubview(radialLabelImageView)
		radialLabelImageView.center = circleCenter
		
		if(IS_IPAD){
			radialChart = UIRadialChart.init(frame:
				CGRect.init(x: self.view.frame.size.width*0.05,
				            y: statusBarHeight+self.view.frame.size.width*0.05,
				            width: self.view.frame.size.width*0.9,
				            height: self.view.frame.size.width * 0.9))
		} else{
			radialChart = UIRadialChart.init(frame: CGRect.init(x: 0, y: statusBarHeight + (self.view.frame.size.width - 320.0) * 0.25, width: self.view.frame.size.width, height: self.view.frame.size.width))
		}
		self.view.addSubview(radialChart)

		radialChartOrigin = CGPoint(x: self.view.bounds.size.width*0.5, y: statusBarHeight + (self.view.frame.size.width - 320.0) * 0.25 + self.view.frame.size.width*0.5 )

		barChart = UIBarChartView.init(frame: CGRect.init(x: 0, y: barChartTop, width: self.view.frame.size.width, height: 200))
		barChart.delegate = self
		self.view.addSubview(barChart)
		
		radialButton.frame = CGRect.init(x: 0, y: 0, width: radialChart.frame.size.width*0.66, height: radialChart.frame.size.height*0.66)
		radialButton.center = radialChart.center
		radialButton.backgroundColor = UIColor.clear
		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchCancel)
		radialButton.addTarget(self, action: #selector(radialTouchCancel), for: .touchDragExit)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDragEnter)
		radialButton.addTarget(self, action: #selector(radialTouchDown), for: .touchDown)
		radialButton.addTarget(self, action: #selector(radialTouchUpInside), for: .touchUpInside)
		self.view.addSubview(radialButton)
		
		preferencesButton.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
		preferencesButton.setImage(UIImage.init(named: "cogs")?.imageWithTint(UIColor.white), for: .normal)
		preferencesButton.center = CGPoint.init(x: self.view.frame.size.width - 22-5, y: statusBarHeight+22+5)
		preferencesButton.addTarget(self, action: #selector(preferencesButtonPressed), for: .touchUpInside)
		self.view.addSubview(preferencesButton)
		
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
//				let keys = Array(sample.values.keys)
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
	
	func barChartDidUpdateSelection(sender: UIBarChartView) {
		let selected = sender.selected
		if selected < self.samples.count{
			self.radialChart.data = self.samples[selected]
		}
	}
		
	
	
	func preferencesButtonPressed(){
		let nav = UINavigationController()
		nav.viewControllers = [Preferences.init(style: .grouped)]
		self.present(nav, animated: true, completion: nil)
	}
	
	func radialTouchDown(){
		radialChart.pressed = true
	}
	
	func radialTouchCancel(){
		radialChart.pressed = false
	}

	func radialTouchUpInside(){
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
	
	func makeCurvedAttributionText(size:CGSize, textRadius:CGFloat) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//		UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
		let context = UIGraphicsGetCurrentContext()!
		// *******************************************************************
		// Scale & translate the context to have 0,0
		// at the centre of the screen maths convention
		// Obviously change your origin to suit...
		// *******************************************************************
		context.translateBy (x: size.width / 2, y: size.height / 2)
		context.scaleBy (x: 1, y: -1)

		Style.shared.centreArcPerpendicular(text: "provided by Allergy Free Austin", context: context, radius: textRadius, angle: -CGFloat.pi*0.5, colour: UIColor.white, font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P12)!, clockwise: false)
//		Style.shared.centreArcPerpendicular(text: name, context: context, radius: textRadius, angle: -textAngle, colour: UIColor.white, font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P12)!, clockwise: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!
	}
	
	/////////////// SCROLL VIEW ///////////////////
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		var pct = scrollView.contentOffset.y / (scrollView.contentSize.height - self.view.bounds.height)
		if pct < 0.0 { pct = 0.0}
		if pct > 1.0 { pct = 1.0}
		let alpha = 1.0 - sqrt(pct)
		self.radialChart.alpha = alpha
		self.radialChart.center = CGPoint(x: radialChartOrigin.x, y: radialChartOrigin.y - pct * 100)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

//
//  UIRadialChart.swift
//  Allergy
//
//  Created by Robby on 4/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class UIRadialChart: UIView {
	
	var data:Sample?{
		didSet{
			self.refreshViewData()
		}
	}
	
	var pressed:Bool = false{
		didSet{
			if self.pressed{
				if let subs = self.circleLayer.sublayers{
					let circle = subs[0] as? CAShapeLayer
					circle?.fillColor = Style.shared.whiteSmoke.cgColor
					self.label.textColor = Style.shared.blue
					self.dayLabel.textColor = Style.shared.blue
				}
			} else{
//				self.circleLayer.opacity = 1.0
				if let subs = self.circleLayer.sublayers{
					let circle = subs[0] as? CAShapeLayer
					circle?.fillColor = UIColor.white.cgColor
					self.label.textColor = UIColor.black
					self.dayLabel.textColor = self.dayLabelGray

				}
			}
			self.layoutSubviews()
		}
	}
	
	// private
	let label = UILabel()
	let arcLayer = CALayer()
	let circleLayer = CALayer()
	
	let dayLabelGray = UIColor(white: 0.66, alpha: 1.0)
	
//	var radialLabels:[UILabel] = []
	
	let radialLabelImageView:UIImageView = UIImageView()
	
	let dayLabel = UILabel()
	
	func refreshViewData() {
		if let d = data{
			let summary = d.generateSummary()
			label.text = Pollen.shared.stringForRating(summary)
			// text size
			switch summary {
			case .veryHeavy: label.font = UIFont.init(name: SYSTEM_FONT_B, size: Style.shared.P40)
			case .none: label.font = UIFont.init(name: SYSTEM_FONT_B, size: Style.shared.P40)
			default: label.font = UIFont.init(name: SYSTEM_FONT_B, size: Style.shared.P48)
			}
			if let date = d.date{
				dayLabel.text = Style.shared.dayStringForDate(date)
			}
		}
//		for label in self.radialLabels{
//			label.removeFromSuperview()
//		}
//		self.radialLabels = []
		self.layoutSubviews()
		redrawGraph()
	}
	
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
	
	func initUI() {
		self.layer.addSublayer(arcLayer)
		self.layer.addSublayer(circleLayer)
		
		let radius:CGFloat = self.frame.width*0.33

		let layer = CAShapeLayer()
		let circle = UIBezierPath.init(arcCenter: CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		layer.path = circle.cgPath
		layer.fillColor = UIColor.white.cgColor
//		circleLayer.isHidden = true
		circleLayer.addSublayer(layer)
		
		label.font = UIFont.init(name: SYSTEM_FONT_B, size: Style.shared.P48)
		label.textColor = UIColor.black
		self.addSubview(label)
		
		dayLabel.font = UIFont.init(name: SYSTEM_FONT, size:Style.shared.P21)
		dayLabel.textColor = self.dayLabelGray
		self.addSubview(dayLabel)
		
		self.addSubview(radialLabelImageView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		label.sizeToFit()
		label.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
		
		dayLabel.sizeToFit()
//		dayLabel.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5 - self.frame.width*0.33 + 50)
		dayLabel.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5 - self.frame.width*0.25 + 50)
	}
	
	func redrawGraph(){
		let radius:CGFloat = self.frame.width*0.33
		let center:CGPoint = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
		arcLayer.sublayers = []

		var barHeight:CGFloat = 40.0 + (self.frame.size.width - 320.0) * 0.18
		if(IS_IPAD){
			barHeight = 110.0;
		}
		if let sample = data{
//			let count = sample.count()
//			for i in 0..<count{
			var report = sample.report().sorted(by: { (a1, a2) -> Bool in
				return ( Float(a1.2) ) < ( Float(a2.2) )
			})
			
			var i = 0
			while i < report.count {
				let removed = report.remove(at: i)
				report.insert(removed, at: 0)
				i += 2
			}
			
			let count = report.count
			for i in 0..<report.count {
				let (_, _, logValue, rating) = report[i]
				var valuePCT:CGFloat = CGFloat(logValue)
				if(valuePCT > 0.75){ valuePCT = 0.75 }
				let thisRadius:CGFloat = valuePCT * barHeight
				let layer = CAShapeLayer()
				let angle = CGFloat(Double.pi * 2 / Double(count))
				let circle = UIBezierPath.init(arcCenter: center, radius: (radius+(barHeight*0.4))+thisRadius, startAngle: angle*CGFloat(i)-CGFloat(Double.pi*0.5), endAngle: angle*CGFloat(i+1)-CGFloat(Double.pi*0.5), clockwise: true)
				circle.addLine(to: center)
				layer.path = circle.cgPath
				
				switch rating {
				case .none:      layer.fillColor = Style.shared.colorNoPollen.cgColor
				case .low:       layer.fillColor = Style.shared.colorLow.cgColor
				case .medium:    layer.fillColor = Style.shared.colorMedium.cgColor
				case .heavy:     layer.fillColor = Style.shared.colorHeavy.cgColor
				case .veryHeavy: layer.fillColor = Style.shared.colorVeryHeavy.cgColor
				}

				arcLayer.addSublayer(layer)
				
			}
			
			
			let size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
			
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

			for i in 0..<report.count {
				let (name, _, logValue, _) = report[i]
				var valuePCT = CGFloat(logValue)
				if(valuePCT > 0.75){ valuePCT = 0.75 }
				let thisRadius:CGFloat = valuePCT * barHeight
				let arcHeight:CGFloat = (barHeight*0.4)+thisRadius
				let angle = CGFloat(Double.pi * 2 / Double(count))
				let textAngle = angle*CGFloat(Float(i)+0.5) - CGFloat(Double.pi*0.5)
				let textRadius = radius + arcHeight*0.5
				if textAngle > 0 && textAngle < CGFloat.pi{
					Style.shared.centreArcPerpendicular(text: name, context: context, radius: textRadius, angle: -textAngle, colour: UIColor.white, font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)!, clockwise: false)
				} else{
					Style.shared.centreArcPerpendicular(text: name, context: context, radius: textRadius, angle: -textAngle, colour: UIColor.white, font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)!, clockwise: true)
				}
			}
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			self.radialLabelImageView.image = image
			self.radialLabelImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		}
		self.bringSubview(toFront: label)
		self.bringSubview(toFront: dayLabel)
		circleLayer.removeFromSuperlayer()
		self.layer.insertSublayer(circleLayer, below: label.layer)
		self.bringSubview(toFront: radialLabelImageView)
		self.radialLabelImageView.center = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
	}

	
		
}

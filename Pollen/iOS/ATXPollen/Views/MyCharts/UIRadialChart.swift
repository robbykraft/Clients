//
//  UIRadialChart.swift
//  Allergy
//
//  Created by Robby on 4/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class UIRadialChart: UIView {
	
	var data:DailyPollenCount?{
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
	
	let attributionText = UIImageView()
	
	func refreshViewData() {
		if let d = data{
			let summary = d.rating()
			label.text = summary.asString()
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
		self.addSubview(label)
		self.addSubview(dayLabel)
		self.addSubview(attributionText)
		self.addSubview(radialLabelImageView)
		label.font = UIFont.init(name: SYSTEM_FONT_B, size: Style.shared.P48)
		label.textColor = UIColor.black
		dayLabel.font = UIFont.init(name: SYSTEM_FONT, size:Style.shared.P21)
		dayLabel.textColor = self.dayLabelGray
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let radius:CGFloat = self.frame.width*0.33
		let layer = CAShapeLayer()
		let circle = UIBezierPath.init(arcCenter: CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		layer.path = circle.cgPath
		layer.fillColor = UIColor.white.cgColor
		circleLayer.sublayers = [layer]
		attributionText.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
		label.sizeToFit()
		label.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
		dayLabel.sizeToFit()
		let paddingDayLabel:CGFloat = dayLabel.frame.size.height*0.1
		dayLabel.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5 - label.frame.size.height*0.5 - dayLabel.frame.size.height*0.5 - paddingDayLabel)
		attributionText.center = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
	}
	
	func redrawGraph(){
		let radius:CGFloat = self.frame.width*0.33
		let center:CGPoint = CGPoint.init(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
		arcLayer.sublayers = []

		var barHeight:CGFloat = 36.0 + (self.frame.size.width - 320.0) * 0.10
		if(IS_IPAD){
			barHeight = 110.0;
		}
		if let sample = data{
			var samples = sample.getSamples().sorted(by:{ $0.logValue < $1.logValue })
			// filter out trace elements
				//.filter{ $0.1 != 0 }
			
			// staggered sort samples
			var i = 0
			while i < samples.count {
				let removed = samples.remove(at: i)
				samples.insert(removed, at: 0)
				i += 2
			}
			
			let count = samples.count
			for i in 0..<samples.count {
				var valuePCT:CGFloat = CGFloat(samples[i].logValue)
				if(valuePCT > 0.75){ valuePCT = 0.75 }
				let thisRadius:CGFloat = valuePCT * barHeight
				let layer = CAShapeLayer()
				let angle = CGFloat(Double.pi * 2 / Double(count))
				let circle = UIBezierPath.init(arcCenter: center, radius: (radius+(barHeight*0.7))+thisRadius, startAngle: angle*CGFloat(i)-CGFloat(Double.pi*0.5), endAngle: angle*CGFloat(i+1)-CGFloat(Double.pi*0.5), clockwise: true)
				circle.addLine(to: center)
				layer.path = circle.cgPath
				
				switch samples[i].rating {
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
			let context = UIGraphicsGetCurrentContext()!
			context.translateBy (x: size.width / 2, y: size.height / 2)
			context.scaleBy (x: 1, y: -1)
			
			let arcFont = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24) ?? UIFont.boldSystemFont(ofSize: Style.shared.P24)

			for i in 0..<samples.count {
				var valuePCT = CGFloat(samples[i].logValue)
				if(valuePCT > 0.75){ valuePCT = 0.75 }
				let thisRadius:CGFloat = valuePCT * barHeight
				let arcHeight:CGFloat = (barHeight*0.7)+thisRadius
				let angle = CGFloat(Double.pi * 2 / Double(count))
				let textAngle = angle*CGFloat(Float(i)+0.5) - CGFloat(Double.pi*0.5)
				let textRadius = radius + arcHeight*0.5
				if textAngle > 0 && textAngle < CGFloat.pi{
					Style.shared.centreArcPerpendicular(text: samples[i].type.name, context: context, radius: textRadius, angle: -textAngle, colour: UIColor.white, font: arcFont, clockwise: false, maxAngle:angle-0.1)
				} else{
					Style.shared.centreArcPerpendicular(text: samples[i].type.name, context: context, radius: textRadius, angle: -textAngle, colour: UIColor.white, font: arcFont, clockwise: true, maxAngle:angle-0.1)
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
		
		attributionText.image = self.makeCurvedAttributionText(size: CGSize.init(width: radius*2, height: radius*2), textRadius: radius-Style.shared.P18)
		self.bringSubview(toFront: attributionText)
	}

	
	func makeCurvedAttributionText(size:CGSize, textRadius:CGFloat) -> UIImage?{
		let attributionFont = UIFont(name: SYSTEM_FONT, size: Style.shared.P11) ?? UIFont.systemFont(ofSize: Style.shared.P12)
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		if let context = UIGraphicsGetCurrentContext(){
			context.translateBy (x: size.width / 2, y: size.height / 2 )
			context.scaleBy (x: 1, y: -1)
			Style.shared.centreArcPerpendicular(text: "Brought to you by Allergen Analytics LLC", context: context, radius: textRadius, angle: -CGFloat.pi*0.5, colour: UIColor.gray, font: attributionFont, clockwise: false, maxAngle:nil)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return image
		}
		return nil
	}
	
		
}

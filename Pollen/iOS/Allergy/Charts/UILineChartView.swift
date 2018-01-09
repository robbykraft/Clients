//
//  UILineChartView.swift
//  Allergy
//
//  Created by Robby on 1/9/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class UILineChartView: UIView {

//	var values:[Date:Int] = [:]{
//		didSet{
//			redrawLayer()
//		}
//	}
	
	// fake data
	var values:[String:Int] = [
			Date().toString() : 3,
			Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: Date())!.toString() : 2,
			Calendar.current.date(byAdding: Calendar.Component.day, value: -2, to: Date())!.toString() : 0,
			Calendar.current.date(byAdding: Calendar.Component.day, value: -6, to: Date())!.toString() : 1,
			Calendar.current.date(byAdding: Calendar.Component.day, value: -7, to: Date())!.toString() : 2,
	]

	
	let barLayer:CALayer = CALayer()
	let watermarkLayer = CALayer()
	
	let lastDateLabel = UILabel()
	let firstDateLabel = UILabel()

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
		
		lastDateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		firstDateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		lastDateLabel.textColor = Style.shared.blue
		firstDateLabel.textColor = Style.shared.blue
		lastDateLabel.textAlignment = .right

		self.addSubview(lastDateLabel)
		self.addSubview(firstDateLabel)
		
		self.layer.addSublayer(watermarkLayer)
		self.layer.addSublayer(barLayer)

		self.layer.borderColor = Style.shared.blue.cgColor
		self.layer.borderWidth = 4

		redrawLayer()
		layoutSubviews()
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
		// graph
		redrawLayer()

		// date labels
		// PREPARE DATA
		let sortedDates = Array(values.keys).sorted{
			var a = Date()
			a.from(string: $0)
			var b = Date()
			b.from(string: $1)
			return a < b
		}
		guard let firstDateString = sortedDates.first else { return }
		guard let lastDateString = sortedDates.last else { return }
		var lastDate = Date()
		lastDate.from(string: lastDateString)
		var firstDate = Date()
		firstDate.from(string: firstDateString)
		
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		firstDateLabel.text = formatter.string(from: firstDate)
		lastDateLabel.text = formatter.string(from: lastDate)
		
		firstDateLabel.sizeToFit()
		lastDateLabel.sizeToFit()
		firstDateLabel.frame = CGRect(x: 0, y: self.bounds.size.height, width: firstDateLabel.frame.size.width, height: firstDateLabel.frame.size.height)
		lastDateLabel.frame = CGRect(x: self.bounds.size.width - lastDateLabel.frame.size.width, y: self.bounds.size.height, width: lastDateLabel.frame.size.width, height: lastDateLabel.frame.size.height)
	}
	

	func redrawLayer(){
		barLayer.sublayers = []
		watermarkLayer.sublayers = []
		
		// PREPARE DATA
		let sortedDates = Array(values.keys).sorted{
			var a = Date()
			a.from(string: $0)
			var b = Date()
			b.from(string: $1)
			return a < b
		}
		guard let firstDateString = sortedDates.first else { return }
		guard let lastDateString = sortedDates.last else { return }
		var lastDate = Date()
		lastDate.from(string: lastDateString)
		var fullDateArray:[String] = []
		var dateI = Date()
		dateI.from(string: firstDateString)
		while !Calendar.current.isDate(dateI, inSameDayAs: lastDate){
			fullDateArray.append(dateI.toString())
			dateI = Calendar.current.date(byAdding: .day, value: 1, to: dateI)!
		}
		fullDateArray.append(lastDateString)
		
		
		let count:CGFloat = CGFloat(fullDateArray.count)
		let lineWidth:CGFloat = 18
		let padH = lineWidth
		let barHeight = self.frame.size.height - padH*2
		
		
		// WATERMARKS
		for i in 0...3{
			let layer = CAShapeLayer()
			let bz = UIBezierPath()
			let yPos = padH + barHeight - barHeight*CGFloat(i)/3
			bz.move(to: CGPoint(x: 4, y: yPos))
			bz.addLine(to: CGPoint(x: self.bounds.size.width - 4, y: yPos))
			layer.path = bz.cgPath
			layer.strokeColor = UIColor(white: 0.75, alpha: 1.0).cgColor
			layer.lineWidth = 2
			layer.lineCap = kCALineCapRound
			watermarkLayer.addSublayer(layer)
		}

		
		// GRAPH DATA
		var i:Int = 1
		let points = fullDateArray.map { (key) -> CGPoint in
			let xPos = self.frame.size.width/(count+1)*CGFloat(i)
			i += 1
			if let value = self.values[key]{
				let valuePct:CGFloat = CGFloat(value) / 3
				return CGPoint(x: xPos, y: padH + barHeight - barHeight*valuePct)
			}
			return CGPoint(x: xPos, y: padH + barHeight)
		}
		
		
		let layer = CAShapeLayer()
		let bz = UIBezierPath()
		bz.move(to: points.first!)
		for point in points{
			bz.addLine(to: point)
		}
		layer.path = bz.cgPath
		layer.strokeColor = Style.shared.blue.cgColor
		layer.lineWidth = lineWidth*0.33
		layer.fillColor = UIColor.clear.cgColor
		layer.lineCap = kCALineCapRound
		barLayer.addSublayer(layer)
		let cirR:CGFloat = lineWidth
		for point in points{
			let circleLayer = CAShapeLayer()
			circleLayer.strokeColor = Style.shared.blue.cgColor
			circleLayer.fillColor = UIColor.white.cgColor
			circleLayer.lineWidth = lineWidth*0.33
			circleLayer.path = UIBezierPath.init(ovalIn: CGRect(x: point.x-cirR*0.5, y: point.y-cirR*0.5, width: cirR, height: cirR)).cgPath
			barLayer.addSublayer(circleLayer)
		}
		
		// data layer
//		for i in 0..<fullDateArray.count{
//			let layer = CAShapeLayer()
//			let bz = UIBezierPath()
//
//			if let data = self.values[fullDateArray[i]]{
//
//				let dataPct:CGFloat = CGFloat(data) / 3
//
//				let xPos:CGFloat = self.frame.size.width/count*CGFloat(i)
//				bz.move(to: CGPoint.init(x: xPos, y: padH + barHeight))
//				bz.addLine(to: CGPoint.init(x: xPos, y: padH + barHeight - barHeight*dataPct))
//				layer.path = bz.cgPath
//				layer.strokeColor = Style.shared.blue.cgColor
//				layer.lineWidth = lineWidth
//				layer.lineCap = kCALineCapRound
//				barLayer.addSublayer(layer)
//			} else{
//				// draw blank space
//			}
//			barLayer.addSublayer(layer)
//		}
	}
	
}

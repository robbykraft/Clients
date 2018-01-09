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
		
		self.layer.addSublayer(barLayer)

		self.layer.borderColor = Style.shared.blue.cgColor
		self.layer.borderWidth = 4

		redrawLayer()
		layoutSubviews()
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
		redrawLayer()
	}
	

	func redrawLayer(){
		barLayer.sublayers = []
		
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
		
		// data layer
		for i in 0..<fullDateArray.count{
			let layer = CAShapeLayer()
			let bz = UIBezierPath()

			if let data = self.values[fullDateArray[i]]{
				
				let dataPct:CGFloat = CGFloat(data) / 3

				let xPos:CGFloat = self.frame.size.width/count*CGFloat(i)
				bz.move(to: CGPoint.init(x: xPos, y: padH + barHeight))
				bz.addLine(to: CGPoint.init(x: xPos, y: padH + barHeight - barHeight*dataPct))
				layer.path = bz.cgPath
				layer.strokeColor = Style.shared.blue.cgColor
				layer.lineWidth = lineWidth
				layer.lineCap = kCALineCapRound
				barLayer.addSublayer(layer)
			} else{
				// draw blank space
			}
			barLayer.addSublayer(layer)
		}
	}
	
}

//
//  UILineChartView.swift
//  Allergy
//
//  Created by Robby on 1/9/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class UILineChartView: UIView {

	var values:[Int] = []{
		didSet{
			redrawLayer()
		}
	}
	
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

		redrawLayer()
		layoutSubviews()
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
	}
	

	func redrawLayer(){
		
		barLayer.sublayers = []
		
//		let lineWidth:CGFloat = 18
//		let spacer:CGFloat = 2
//		let padLabel:CGFloat = 20
//		let padW:CGFloat = 0.5 * (self.frame.size.width - CGFloat((count-1) * (lineWidth+spacer)))
//		let padH:CGFloat = 20 + lineWidth
//
//		let barHeight = self.frame.size.height-(padH*2) - padLabel
//
//		// data layer
//		for i in 0..<values.count{
//			let layer = CAShapeLayer()
//			let bz = UIBezierPath()
//			let xPos:CGFloat = padW + CGFloat(count-1-CGFloat(i)) * (lineWidth+spacer)
//			bz.move(to: CGPoint.init(x: xPos, y: padH + barHeight))
//			bz.addLine(to: CGPoint.init(x: xPos, y: padH + barHeight - barHeight*CGFloat(values[i])))
//			layer.path = bz.cgPath
//			layer.strokeColor = Style.shared.lightBlue.cgColor
//			if i == selected{
//				layer.strokeColor = Style.shared.blue.cgColor
//			}
//			layer.lineWidth = lineWidth
//			layer.lineCap = kCALineCapRound
//			barLayer.addSublayer(layer)
//		}
	}
	
}

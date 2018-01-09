//
//  UIChartView.swift
//  Allergy
//
//  Created by Robby on 4/10/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit


protocol BarChartDelegate: class {
	func barChartDidUpdateSelection(sender: UIBarChartView)
}

class UIBarChartView: UIView {
	
	weak var delegate:BarChartDelegate? // for calling completed button press function
	var selected = 0
	
	var values:[Float] = []{
		didSet{
			redrawLayer()
		}
	}
	var labels:[String] = []{
		didSet{
			for i in 0..<labels.count{
				if i < uiLabels.count{
					uiLabels[i].text = labels[i]
				}
			}
			layoutSubviews()
		}
	}
	
	var uiLabels:[UILabel] = []
	
	let count:CGFloat = 15
	
	let barLayer:CALayer = CALayer()
	let watermarkLayer:CALayer = CALayer()
	
	var touchAreas:[CGRect] = []
	

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
		
		// UILabels
		for _ in 0..<Int(count){
			let label = UILabel()
			label.font = UIFont.init(name: SYSTEM_FONT, size: Style.shared.P11)
			label.textColor = UIColor.black
			self.addSubview(label)
			uiLabels.append(label)
		}
		
		self.layer.addSublayer(watermarkLayer)
		self.layer.addSublayer(barLayer)

//		self.backgroundColor = UIColor.lightGray
		redrawLayer()
		layoutSubviews()
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
		let lineWidth:CGFloat = 18
		let spacer:CGFloat = 2
		let padLabel:CGFloat = 20
		let padW:CGFloat = 0.5 * (self.frame.size.width - CGFloat((count-1) * (lineWidth+spacer)))
		let padH:CGFloat = 20 + lineWidth

		// uilabels
		for i in 0..<Int(count){
			if(uiLabels.count > i){
				let xPos:CGFloat = padW + CGFloat(count-1-CGFloat(i)) * (lineWidth+spacer)
				uiLabels[i].sizeToFit()
				uiLabels[i].center = CGPoint.init(x: xPos, y: self.frame.size.height-padH)
			}
		}
	}
	
	func redrawLayer(){

		barLayer.sublayers = []
		watermarkLayer.sublayers = []
		
		touchAreas = []
		
		let lineWidth:CGFloat = 18
		let spacer:CGFloat = 2
		let padLabel:CGFloat = 20
		let padW:CGFloat = 0.5 * (self.frame.size.width - CGFloat((count-1) * (lineWidth+spacer)))
		let padH:CGFloat = 20 + lineWidth
	
		let barHeight = self.frame.size.height-(padH*2) - padLabel

		// watermarks
		for i in 0..<Int(count){
			let layer = CAShapeLayer()
			let bz = UIBezierPath()
			let xPos:CGFloat = padW + CGFloat(i)*(lineWidth+spacer)
			bz.move(to: CGPoint.init(x: xPos, y: self.frame.size.height-padH - padLabel))
			bz.addLine(to: CGPoint.init(x: xPos, y: padH))
			layer.path = bz.cgPath
			layer.strokeColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
			layer.lineWidth = lineWidth
			layer.lineCap = kCALineCapRound
			watermarkLayer.addSublayer(layer)
			touchAreas.append(CGRect(x: xPos-lineWidth*0.5, y:padH-lineWidth*0.5, width: lineWidth, height: self.frame.size.height-padH*2 - padLabel+lineWidth*0.5*2))
		}

		// data layer
		for i in 0..<values.count{
			let layer = CAShapeLayer()
			let bz = UIBezierPath()
			let xPos:CGFloat = padW + CGFloat(count-1-CGFloat(i)) * (lineWidth+spacer)
			bz.move(to: CGPoint.init(x: xPos, y: padH + barHeight))
			bz.addLine(to: CGPoint.init(x: xPos, y: padH + barHeight - barHeight*CGFloat(values[i])))
			layer.path = bz.cgPath
			layer.strokeColor = Style.shared.lightBlue.cgColor
			if i == selected{
				layer.strokeColor = Style.shared.blue.cgColor
			}
			layer.lineWidth = lineWidth
			layer.lineCap = kCALineCapRound
			barLayer.addSublayer(layer)
		}
		
	}
	
	func didTouchIn(number:Int){
		if selected != number{
			selected = number
			if delegate != nil{
				delegate?.barChartDidUpdateSelection(sender: self)
			}
			redrawLayer()
		}
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first{
			for i in 0 ..< touchAreas.count{
				let area = touchAreas[i]
				if(area.contains(touch.location(in: self))){
					self.didTouchIn(number: 14 - i)
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first{
			for i in 0 ..< touchAreas.count{
				let area = touchAreas[i]
				if(area.contains(touch.location(in: self))){
					self.didTouchIn(number: 14 - i)
				}
			}
		}
	}

}

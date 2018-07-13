//
//  OverylayChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension OverylayChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let intValue = Int(value)
		if intValue < 0 || intValue >= ChartData.shared.clinicDataYearDates.count { return "" }
		let date = ChartData.shared.clinicDataYearDates[intValue]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
//		if      zoomPage == 0 { dateFormatter.dateFormat = "MMM yyyy" }
//		else if zoomPage == 1 { dateFormatter.dateFormat = "MMM d" }
		return dateFormatter.string(from: date)
	}
}

class OverylayChartView: UIView, ChartViewDelegate{

	// charts
	let chartView = CombinedChartView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() { self.init(frame: CGRect.zero) }
	required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }
	
	func initUI(){
		self.addSubview(chartView)
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		
		chartView.legend.entries = []
		chartView.legend.form = .none
		chartView.drawBarShadowEnabled = false
		chartView.highlightFullBarEnabled = false
		
		
		chartView.drawOrder = [DrawOrder.bar.rawValue,
//							   DrawOrder.bubble.rawValue,
//							   DrawOrder.candle.rawValue,
							   DrawOrder.line.rawValue,
//							   DrawOrder.scatter.rawValue
		]
		
		chartView.xAxis.valueFormatter = self
		chartView.gridBackgroundColor = .clear
		chartView.drawGridBackgroundEnabled = false
		chartView.scaleYEnabled = false
		chartView.getAxis(.left).drawLabelsEnabled = false
		chartView.getAxis(.right).drawLabelsEnabled = false
		chartView.xAxis.granularity = 1
		chartView.getAxis(.left).gridColor = .clear
		chartView.getAxis(.right).gridColor = .clear
		chartView.scaleXEnabled = true
		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.drawAxisLineEnabled = false
//		chartView.xAxis.forceLabelsEnabled = true
		chartView.chartDescription?.enabled = false

//		data.setValueFormatter(self)

//		let rightAxis = chartView.rightAxis
//		rightAxis.axisMinimum = 0
		
//		let leftAxis = chartView.leftAxis
//		leftAxis.axisMinimum = 0
		
//		let xAxis = chartView.xAxis
//		xAxis.labelPosition = .bothSided
//		xAxis.axisMinimum = 0
//		xAxis.granularity = 1
//		xAxis.valueFormatter = self
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height*0.5)
	}
	
	func reloadData(){
		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		
		let data = CombinedChartData()
		data.lineData = ChartData.shared.dailyAllergyDataLineChart()
		data.barData = ChartData.shared.dailyClinicDataBarChartData()
//		data.bubbleData = generateBubbleData()
//		data.scatterData = generateScatterData()
		chartView.xAxis.axisMaximum = data.xMax + 0.25
		chartView.data = data
	}
	
}

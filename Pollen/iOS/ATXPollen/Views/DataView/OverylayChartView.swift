//
//  OverylayChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

protocol OverlayChartDelegate{
	func didSelectDate(_ date:Date);
}

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
	var delegate:OverlayChartDelegate?
	
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
		
		chartView.drawOrder = [DrawOrder.line.rawValue,
							   DrawOrder.bar.rawValue,
							   DrawOrder.scatter.rawValue ]
		
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
		chartView.chartDescription?.enabled = false
	}
	
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		let index = Int(entry.x)
		if index < 0 || index >= ChartData.shared.clinicDataYearDates.count{ return }
		let date = ChartData.shared.clinicDataYearDates[index]
		delegate?.didSelectDate(date);
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
	}
	
	func randomBool() -> Bool {
		return arc4random_uniform(6) == 0
	}

	func reloadData(){
		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		
		let data = CombinedChartData()
		data.lineData = ChartData.shared.dailyClinicDataLineChartData()
		data.barData = ChartData.shared.dailyAllergyDataBarChartData()
		
		chartView.doubleTapToZoomEnabled = false
		
		data.scatterData = ChartData.shared.scatterData(from: ChartData.shared.exposureDataByTypes)
		chartView.xAxis.axisMaximum = data.xMax + 0.25
		chartView.data = data
		chartView.legend.enabled = false
	}
	
}

//
//  ChartStyles.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
	private let dateFormatter = DateFormatter()
	override init() {
		super.init()
		dateFormatter.dateFormat = "dd MMM HH:mm"
	}
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		return dateFormatter.string(from: Date(timeIntervalSince1970: value))
	}
}

extension MyChartsView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//		return months[Int(value) % months.count]
		if Int(value) < self.dataDates.count{
			let date = self.dataDates[Int(value)]
			return Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: date)]
		}
		return "\(Int(value))"
	}
}


extension MyChartsView {
	
	func setupFilledChart(_ chart: LineChartView, data: LineChartData, color: UIColor) {
		(data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = color
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
//		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		chart.data = data
		chart.animate(xAxisDuration: 0.5)
	}
	
	func setupDateChart(_ chart: LineChartView, data: LineChartData) {
		chart.backgroundColor = UIColor.white
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
//		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
			chart.xAxis.labelFont = font
		}
		chart.xAxis.granularity = 1
		chart.xAxis.centerAxisLabelsEnabled = true
		chart.xAxis.valueFormatter = self
		chart.xAxis.enabled = true
		chart.xAxis.drawAxisLineEnabled = false
		chart.xAxis.drawGridLinesEnabled = false
		chart.xAxis.drawLabelsEnabled = true
		
		chart.xAxis.axisMaximum = data.xMax + 0.25
		chart.data = data
	}

	func setupScatterChart(_ chart: ScatterChartView, data: ScatterChartData, color: UIColor) {
//		(data.getDataSetByIndex(0) as! ScatterChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = color
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
//		chart.leftAxis.spaceTop = 0.4
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		chart.data = data
		chart.animate(xAxisDuration: 0.5)
	}

	
	func setupBarChart(_ chart: BarChartView, data: BarChartData, color: UIColor) {
//		(data.getDataSetByIndex(0) as! BarChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = color
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
//		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		chart.data = data
		chart.animate(xAxisDuration: 0.5)
	}
	
}

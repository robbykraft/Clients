//
//  ChartStyles.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts

//class ChartStyles:IAxisValueFormatter {
//	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//		let intValue = Int(value)
//		if intValue < 0 || intValue >= ChartData.shared.clinicDataYearDates.count { return "" }
//		let date = ChartData.shared.clinicDataYearDates[intValue]
//		let dateFormatter = DateFormatter()
//		if      zoomPage == 0 { dateFormatter.dateFormat = "MMM yyyy" }
//		else if zoomPage == 1 { dateFormatter.dateFormat = "MMM d" }
//		return dateFormatter.string(from: date)
//	}
//}

extension PollenTypeChartView {
	
	func setupFilledChart(_ chart: LineChartView, data: LineChartData) {
		(data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = Style.shared.blue
		chart.delegate = self
		chart.backgroundColor = Style.shared.whiteSmoke
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15){
			chart.noDataFont = font
		}
		chart.noDataText = "waiting on data.."
		chart.data = data
//		chart.animate(xAxisDuration: 0.5)
	}
	
	
	func setupBarChart(_ chart: BarChartView, data: BarChartData) {
//		(data.getDataSetByIndex(0) as! BarChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = Style.shared.whiteSmoke
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15){
			chart.noDataFont = font
		}
		chart.noDataText = "waiting on data.."
		chart.data = data
	}
	
	func setupDateChart(_ chart: BarChartView, data: BarChartData) {
		chart.backgroundColor = Style.shared.whiteSmoke
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
			chart.xAxis.labelFont = font
		}
		chart.xAxis.valueFormatter = self
		chart.xAxis.enabled = true
		chart.xAxis.granularity = 30.0
//		chart.xAxis.granularity = 1.0
		chart.xAxis.drawAxisLineEnabled = false
		chart.xAxis.drawGridLinesEnabled = false
		chart.xAxis.drawLabelsEnabled = true
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15){
			chart.noDataFont = font
		}
		chart.noDataText = "waiting on data.."
		chart.data = data
	}

	func setupScatterChart(_ chart: ScatterChartView, data: ScatterChartData) {
//		(data.getDataSetByIndex(0) as! ScatterChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = Style.shared.whiteSmoke
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.resetViewPortOffsets()
		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
//		chart.leftAxis.spaceTop = 0.4
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.doubleTapToZoomEnabled = false
		chart.data = data
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15){
			chart.noDataFont = font
		}
		chart.noDataText = "waiting on data.."
		chart.animate(xAxisDuration: 0.5)
	}

}

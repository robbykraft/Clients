//
//  ChartStyles.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts

//public class DateValueFormatter: NSObject, IAxisValueFormatter {
//	private let dateFormatter = DateFormatter()
//	override init() {
//		super.init()
//		dateFormatter.dateFormat = "dd MMM HH:mm"
//	}
//	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//		return dateFormatter.string(from: Date(timeIntervalSince1970: value))
//	}
//}

extension PollenTypeChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//		return "\(Int(value))"
		if Int(value) >= self.dataDates.count || Int(value) < 0{ return "" }
		switch zoomPage {
		case 0:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM yyyy"
			let date = self.dataDates[Int(value)]
			return dateFormatter.string(from: date)
		case 1:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d"
			let date = self.dataDates[Int(value)]
			return dateFormatter.string(from: date)
//			return Calendar.current.weekdaySymbols[(Calendar.current.component(.weekday, from: date)+6)%7]
		default:
			return ""
		}
//		if Int(value) < self.dataDates.count && Int(value) >= 0{
//			let dateFormatter = DateFormatter()
//			dateFormatter.dateFormat = "MMM d"
//			let date = self.dataDates[Int(value)]
//			return dateFormatter.string(from: date)
////			return Calendar.current.weekdaySymbols[(Calendar.current.component(.weekday, from: date)+6)%7]
//		}
//		return ""
	}
}


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

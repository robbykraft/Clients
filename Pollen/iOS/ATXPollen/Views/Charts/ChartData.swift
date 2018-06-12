//
//  ChartData.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts

extension MyChartsView{

	func barChartData(from pollenSamples:[PollenSamples], color:UIColor) -> BarChartData {
		let logValues = pollenSamples
			.map({ let ss = $0.strongestSample(); return (ss != nil) ? Double(ss!.logValue) : 0.0 })
			.enumerated()
			.map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
		let colors = pollenSamples.map({ Style.shared.colorFor(rating: $0.rating()) })
		let set1 = BarChartDataSet(values: logValues, label: "Pollen Data")
		set1.setColors(colors, alpha: 1.0)
//		set1.setColor(Style.shared.green)
		set1.highlightEnabled = true
		set1.highlightColor = Style.shared.orange
		set1.drawValuesEnabled = false
		return BarChartData(dataSet: set1)
	}
	
	func filledChartData(from array:[Double], color:UIColor) -> LineChartData {
		let values = array.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
		let set1 = LineChartDataSet(values: values, label: "Lines")
		set1.lineWidth = 0.1
//		set1.circleRadius = 5.0
//		set1.circleHoleRadius = 2.5
//		set1.setColor(color)
//		set1.setCircleColor(color)
		set1.highlightColor = Style.shared.orange
		set1.highlightLineWidth = 1
		set1.drawValuesEnabled = false
		set1.drawCirclesEnabled = false
		set1.drawFilledEnabled = true
		set1.fillAlpha = 1
		set1.fillColor = color
//		set1.cubicIntensity = 0.5
		set1.mode = .cubicBezier
		return LineChartData(dataSet: set1)
	}
	
	func scatterData(from array:[[Bool]], color:UIColor) -> ScatterChartData{
		let colors = [Style.shared.orange, Style.shared.lightBlue, Style.shared.purple, Style.shared.softBlue, Style.shared.red]
		let dataSets = array.enumerated().map { (i, valueArray) -> ChartDataSet in
			let values = valueArray.map{ return $0 ? i+1 : 0
				}.enumerated().map({ (j, value) -> ChartDataEntry in
					return ChartDataEntry(x: Double(j), y: Double(value)/6)
				}).filter({ $0.y != 0.0 })
			let set = ScatterChartDataSet(values: values + [ChartDataEntry(x: 0, y: 0)], label: exposureTypes[i].asString())
			set.setScatterShape(.circle)
			set.scatterShapeHoleColor = colors[i%5]
			set.scatterShapeHoleRadius = 3.5
			set.drawValuesEnabled = false
			set.setColor(colors[i%5])
			set.scatterShapeSize = 8
			return set
		}
		return ScatterChartData(dataSets: dataSets)
	}
	
	func dateChartData(from array:[Date], level:Calendar.Component) -> BarChartData {
//		let values = array.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: 0, data: $0.element as AnyObject) })
//		let dateSet = LineChartDataSet(values: values, label: "Dates")
		
		let entries = (0..<array.count).map { (i) -> BarChartDataEntry in
			return BarChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
		}
		
		let set = BarChartDataSet(values: entries, label: "Dates")
//		let set = LineChartDataSet(values: entries, label: "Dates")
		set.setColor(UIColor.clear)
//		set.lineWidth = 2.5
//		set.setCircleColor(UIColor.clear)
//		set.circleRadius = 5
//		set.circleHoleRadius = 2.5
//		set.fillColor = UIColor.clear
		set.setColor(UIColor.clear)
//		set.mode = .cubicBezier
		set.drawValuesEnabled = true
//		set.valueFont = .systemFont(ofSize: 10)
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
			set.valueFont = font
		}
		set.valueTextColor = UIColor.clear
		set.axisDependency = .left
		return BarChartData(dataSet: set)
	}
}

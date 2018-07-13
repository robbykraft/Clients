//
//  PollenTypeChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 5/16/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension PollenTypeChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let intValue = Int(value)
		if intValue < 0 || intValue >= ChartData.shared.clinicDataYearDates.count { return "" }
		let date = ChartData.shared.clinicDataYearDates[intValue]
		let dateFormatter = DateFormatter()
		if      zoomPage == 0 { dateFormatter.dateFormat = "MMM yyyy" }
		else if zoomPage == 1 { dateFormatter.dateFormat = "MMM d" }
		return dateFormatter.string(from: date)
	}
}

class PollenTypeChartView: UIView, ChartViewDelegate {
	
	// charts
	var allCharts:[BarLineChartViewBase] = []
	let dateChart = BarChartView()
	let groupCharts:[BarLineChartViewBase] = [BarChartView(), BarChartView(), BarChartView(), BarChartView()]
	let symptomCharts = [LineChartView(), ScatterChartView()]

	// ui kit
	let chartLabels = [UILabel(), UILabel(), UILabel(), UILabel()]
	let dateLabel = UILabel()
	
	var zoomPage:Int = 0{
		willSet{
			if(zoomPage != newValue){
				switch newValue{
				case 0: dateChart.xAxis.granularity = 30.0
				case 1: dateChart.xAxis.granularity = 1.0
				default: break;
				}
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() { self.init(frame: CGRect.zero) }
	required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }
	
	func initUI(){		

		allCharts = [dateChart] + groupCharts + symptomCharts
		allCharts.forEach({
			self.addSubview($0)
			$0.delegate = self
		})
		
		chartLabels.enumerated().forEach({
			$0.element.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			$0.element.textColor = .black
			$0.element.text = ChartData.shared.pollenTypeGroups[$0.offset].asString()
			$0.element.textAlignment = .left
			$0.element.backgroundColor = Style.shared.whiteSmoke
			$0.element.layer.cornerRadius = 3
			$0.element.clipsToBounds = true
			$0.element.sizeToFit()
			self.addSubview($0.element)
		})		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		dateChart.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 40)
		
		let h:CGFloat = self.bounds.size.height*0.13
		let dateChartHeight:CGFloat = h*0.33
		dateChart.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: dateChartHeight)

		allCharts.filter({$0 != dateChart}).enumerated().forEach({
			$0.element.frame = CGRect(x: 0, y: h*CGFloat($0.offset) + dateChartHeight, width: self.bounds.size.width, height: h)
		})
		chartLabels.enumerated().forEach({
			$0.element.center = CGPoint(x: 10 + $0.element.frame.size.width*0.5, y: dateChartHeight + h*CGFloat($0.offset) + $0.element.frame.size.height*0.5)
		})
	}
	
	func getSymptomChartsFrame() -> CGRect{
		guard let firstChart = symptomCharts.first else { return CGRect.zero }
		guard let lastChart = symptomCharts.last else { return CGRect.zero }
		return CGRect(x: firstChart.frame.origin.x, y: firstChart.frame.origin.y, width: firstChart.frame.size.width, height: lastChart.frame.bottom - firstChart.frame.origin.y)
	}
	
	func reloadData(){		
		if ChartData.shared.clinicDataYearDates.count == 0{ return}

		setupDateChart(dateChart, data:dateChartData(from: ChartData.shared.clinicDataYearDates, level:.day))
		
		// clinicSampleData
		ChartData.shared.dailyClinicDataByGroupsBarChartData().enumerated().forEach { (offset, chartData) in
			setupBarChart(groupCharts[offset] as! BarChartView, data: chartData)
		}
		setupFilledChart(symptomCharts[0] as! LineChartView, data: ChartData.shared.dailyAllergyDataFilledLineChart())
		setupScatterChart(symptomCharts[1] as! ScatterChartView, data: ChartData.shared.scatterData(from: ChartData.shared.exposureDataValues))
		
		// reset views
		allCharts.forEach { (chart) in
			chart.zoom(scaleX: 2, scaleY: 1, x: chart.frame.size.width*1.5, y: 0)
		}
		zoomPage = 1
		dateChart.xAxis.granularity = 1.0

	}
	
	func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
		let otherCharts = allCharts.filter({ chartView != $0 })
		otherCharts.forEach { (chart) in
			chart.viewPortHandler.refresh(newMatrix: chartView.viewPortHandler.touchMatrix, chart: chart, invalidate: false)
		}
	}
	func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
		let otherCharts = allCharts.filter({ chartView != $0 })
		otherCharts.forEach { (chart) in
			chart.viewPortHandler.refresh(newMatrix: chartView.viewPortHandler.touchMatrix, chart: chart, invalidate: false)
		}
		if let chart = otherCharts.first{
			zoomPage = (chart.viewPortHandler.scaleX < 4) ? 0 : 1
		}
	}
	
	func chartValueNothingSelected(_ chartView: ChartViewBase) {
		allCharts
			.filter({ chartView != $0 })
			.filter({ $0 != dateChart })
			.forEach { (chart) in
				chart.highlightValue(x: -1, dataSetIndex: 1, callDelegate: false)
		}
		self.chartLabels.enumerated().forEach({ $0.element.text = ChartData.shared.pollenTypeGroups[$0.offset].asString() })
	}
	
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		allCharts
			.filter({ chartView != $0 })
			.filter({ $0 != dateChart })
			.forEach { (chart) in
				var y:Double = 0
				if let data = chart.data{
					if let foundentry = data.dataSets[0].entriesForXValue(highlight.x).first{
						y = foundentry.y
					}
				}
				chart.highlightValue(x: highlight.x, y: y, dataSetIndex: highlight.dataSetIndex, dataIndex: highlight.dataIndex, callDelegate: false)
		}
		// clear out entry
		self.chartLabels.enumerated().forEach({ $0.element.text = ChartData.shared.pollenTypeGroups[$0.offset].asString() })
		// deta
		ChartData.shared.dailyClinicDataByGroups
			.map { $0[Int(highlight.x)] }
			.enumerated()
			.forEach({
				if let strongest = $0.element.strongestSample(){
					self.chartLabels[$0.offset].text = "\(ChartData.shared.pollenTypeGroups[$0.offset].asString()): \(strongest.rating.asString()) (\(strongest.value))"
				}
			})
		self.chartLabels.forEach({ $0.sizeToFit() })
	}

}




extension PollenTypeChartView{
	
	
	func dateChartData(from array:[Date], level:Calendar.Component) -> BarChartData {
		let chartValues = array
			.enumerated()
			.map({ BarChartDataEntry(x: Double($0.offset), y: 0.0) })
		let set1 = BarChartDataSet(values: chartValues, label: "Dates")
		set1.setColor(UIColor.clear)
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
			set1.valueFont = font
		}
		set1.highlightEnabled = false
		set1.drawValuesEnabled = false
//		set.valueTextColor = UIColor.clear
//		set.axisDependency = .left
		return BarChartData(dataSet: set1)
	}
}

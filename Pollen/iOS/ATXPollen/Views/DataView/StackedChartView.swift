//
//  StackedChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/29/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension StackedChartView: IAxisValueFormatter {
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

class StackedChartView: UIView, ChartViewDelegate {
	
	// charts
	let chartView = BarChartView()
	
	var zoomPage:Int = 0{
		willSet{
			if(zoomPage != newValue){
				switch newValue{
//				case 0: dateChart.xAxis.granularity = 30.0
//				case 1: dateChart.xAxis.granularity = 1.0
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
		self.addSubview(chartView)
		chartView.delegate = self
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		dateChart.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 40)
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
	}
	
	func reloadData(){
		if ChartData.shared.clinicDataYearDates.count == 0{ return}

		let stackedData = ChartData.shared.dailyClinicDataByGroups.map { (samples:[DailyPollenCount]) -> [Double] in
			return samples.map({ (s:DailyPollenCount) -> Double in
				let ss = s.strongestSample()
				return (ss != nil) ? Double(ss!.logValue) : Double(0.0)
			})
		}
		
		let innerCount = stackedData[0].count
		var yVals:[BarChartDataEntry] = []
		for i in 0..<innerCount{
			let column = [ stackedData[3][i], stackedData[2][i], stackedData[0][i], stackedData[1][i] ]
			yVals.append(BarChartDataEntry(x: Double(i), yValues: column))
		}
		let set = BarChartDataSet(values: yVals, label: "Stacked Clinic Data")
		set.drawIconsEnabled = false
//		set.colors = [Style.shared.red, Style.shared.orange, Style.shared.blue, Style.shared.green]
		set.colors = [Style.shared.green, Style.shared.blue, Style.shared.red, Style.shared.orange ]
//		set.stackLabels = speciesGroups.map({ $0.asString() })
		set.stackLabels = [
			ChartData.shared.pollenTypeGroups[3].asString(),
			ChartData.shared.pollenTypeGroups[2].asString(),
			ChartData.shared.pollenTypeGroups[0].asString(),
			ChartData.shared.pollenTypeGroups[1].asString()
		]
		let data = BarChartData(dataSet: set)
		chartView.fitBars = true
		chartView.scaleYEnabled = false
		data.setDrawValues(false)
		chartView.data = data
		chartView.leftAxis.drawLabelsEnabled = false
		chartView.rightAxis.drawLabelsEnabled = false
		chartView.drawGridBackgroundEnabled = false

		chartView.xAxis.valueFormatter = self
		chartView.getAxis(.left).drawLabelsEnabled = false
		chartView.getAxis(.right).drawLabelsEnabled = false
		chartView.getAxis(.left).drawGridLinesEnabled = false
		chartView.getAxis(.right).drawGridLinesEnabled = false
		chartView.xAxis.drawGridLinesEnabled = false
		chartView.chartDescription?.enabled = false

	}
	
}

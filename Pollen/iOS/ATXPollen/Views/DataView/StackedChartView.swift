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
		return ""
		//		return "\(Int(value))"
		if Int(value) >= ChartData.shared.clinicDataYearDates.count || Int(value) < 0{ return "" }
		switch zoomPage {
		case 0:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM yyyy"
			let date = ChartData.shared.clinicDataYearDates[Int(value)]
			return dateFormatter.string(from: date)
		case 1:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d"
			let date = ChartData.shared.clinicDataYearDates[Int(value)]
			return dateFormatter.string(from: date)
		//			return Calendar.current.weekdaySymbols[(Calendar.current.component(.weekday, from: date)+6)%7]
		default:
			return ""
		}
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
		
		let h:CGFloat = self.bounds.size.height*0.5
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: h)
	}
	
	func reloadData(){
		
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

//
//  MonthlyBarChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/3/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension MonthlyBarChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		return ""
//		return "\(Int(value))"
//		print("requesting \(value)")
		if value < 0{ return "" }

		let months = Array((0..<12).reversed()).map { (i) -> Date in
			var minusMonth = DateComponents()
			minusMonth.month = -i
			return Calendar.current.date(byAdding: minusMonth, to: Date())!
		}
		let mIndex = Calendar.current.component(.month, from: months[ (Int(value)) ]) - 1
		if mIndex >= 0 && mIndex < 12{
			return Calendar.current.shortMonthSymbols[mIndex]
		}
		return ""
	}
}

class MonthlyBarChartView: UIView, ChartViewDelegate {
	
	// charts
	let chartView = BarChartView()
	
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
		
		let groupSpace = 0.08
		let barSpace = 0.00
		let barWidth = 0.23
		// (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"
		
		let yVals = ChartData.shared.monthlyStrongestSampleByGroups.map { (sampleArray) -> [Double] in
			return sampleArray.map({ (sample) -> Double in
				return Double(sample.logValue)
			})
			}.map { (array) -> [BarChartDataEntry] in
				return array.enumerated().map({ (i, element) -> BarChartDataEntry in
					return BarChartDataEntry(x: Double(i), y: element)
				})
			}
		
//		let yVals: (Int) -> BarChartDataEntry = { (i) -> BarChartDataEntry in
//			return BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(UInt32(randomMultiplier))))
//		}
		
		let set1 = BarChartDataSet(values: yVals[0], label: ChartData.shared.pollenTypeGroups[0].asString())
		let set2 = BarChartDataSet(values: yVals[1], label: ChartData.shared.pollenTypeGroups[1].asString())
		let set3 = BarChartDataSet(values: yVals[2], label: ChartData.shared.pollenTypeGroups[2].asString())
		let set4 = BarChartDataSet(values: yVals[3], label: ChartData.shared.pollenTypeGroups[3].asString())

		set1.setColor(Style.shared.red);
		set2.setColor(Style.shared.orange);
		set3.setColor(Style.shared.blue);
		set4.setColor(Style.shared.green);

		let data = BarChartData(dataSets: [set1, set2, set3, set4])
		data.setValueFont(UIFont(name: SYSTEM_FONT, size: Style.shared.P11))
//		data.setValueFormatter(LargeValueFormatter())
		set1.drawValuesEnabled = false
		set2.drawValuesEnabled = false
		set3.drawValuesEnabled = false
		set4.drawValuesEnabled = false
		data.setDrawValues(false)
		chartView.xAxis.valueFormatter = self
		chartView.gridBackgroundColor = .clear
		chartView.drawGridBackgroundEnabled = false
		chartView.scaleYEnabled = false
		chartView.getAxis(.left).drawLabelsEnabled = false
		chartView.getAxis(.right).drawLabelsEnabled = false
		chartView.xAxis.granularity = 1
//		chartView.getAxis(.left).setGranularity(0);
//		chartView.getAxis(.right).setGranularity(0);
		chartView.getAxis(.left).gridColor = .clear
		chartView.getAxis(.right).gridColor = .clear
		chartView.scaleXEnabled = false
		chartView.xAxis.setLabelCount(13, force: true)
		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.drawAxisLineEnabled = false
//		chartView.xAxis.forceLabelsEnabled = true
//		data.setValueFormatter(self)
		chartView.chartDescription?.enabled = false

		// specify the width each bar should have
		data.barWidth = barWidth
		data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
		chartView.data = data

	}
}

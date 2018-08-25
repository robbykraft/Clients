//
//  DailyDetailChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 8/3/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension DailyDetailChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let intValue = Int(value)
		if let columns = axisNames{
			if intValue < columns.count{
				return columns[intValue]
			}
		}
		return ""
	}
}

class DailyDetailChartView: UIView {

	let dateLabel = UILabel()
	let dateUnderline = UIView()
	let bottomUnderline = UIView()
	let scrollView = UIScrollView()
	let traceLabel = UILabel()
	
	// charts
	let chartView = HorizontalBarChartView()
	var axisNames:[String]?

	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	func initUI(){
		dateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		dateLabel.textColor = .black
		dateUnderline.backgroundColor = .black
		bottomUnderline.backgroundColor = .black
		traceLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
		traceLabel.textColor = .black
		traceLabel.numberOfLines = 0
		self.addSubview(dateLabel)
		self.addSubview(dateUnderline)
		self.addSubview(bottomUnderline)
		self.addSubview(traceLabel)
		self.addSubview(chartView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		dateLabel.sizeToFit()
		dateLabel.frame.origin = CGPoint(x: 20, y: 0)
		dateUnderline.frame = CGRect(x: 0, y: 0, width: dateLabel.frame.size.width, height: 1)
		dateUnderline.center = CGPoint(x: dateLabel.center.x, y: dateLabel.center.y + dateLabel.frame.size.height*0.5)
		bottomUnderline.frame = CGRect(x: dateUnderline.frame.origin.x, y: self.bounds.size.height, width: self.bounds.size.width - dateUnderline.frame.origin.x*2, height: 1)

		traceLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width-40, height: 200)
		traceLabel.sizeToFit()
		traceLabel.frame.origin = CGPoint(x: 20, y: self.bounds.size.height - traceLabel.frame.size.height)
		
		if let entries = chartView.data?.dataSets.first?.entryCount{
			chartView.frame = CGRect(x: 0, y: 28, width: self.bounds.size.width, height: self.bounds.size.height * 0.12 + self.bounds.size.height * 0.1 * CGFloat(entries))
		} else{
			chartView.frame = CGRect(x: 0, y: 28, width: self.bounds.size.width, height: self.bounds.size.height * 0.7)
		}
		
		if chartView.frame.size.height > self.bounds.size.height * 0.666 { chartView.frame.size.height = self.bounds.size.height * 0.666 }
	}
	
	func reloadData(with date:Date){
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d, yyyy"
		dateLabel.text = formatter.string(from: date)
		dateLabel.sizeToFit()

		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		
		if let todayCounts = ClinicData.shared.dailyCounts.filter({
			if let d = $0.date{ return Calendar.current.isDate(d, inSameDayAs: date) }
			return false
		}).first{
			let samples = todayCounts.getSamples()
			let nonTraceSamples = samples.filter({$0.value != 0})
			axisNames = nonTraceSamples.map({ $0.type.name })
			let yVals = nonTraceSamples
				.map({ Double($0.logValue) })
				.enumerated().map { (arg) -> BarChartDataEntry in
					let (i, element) = arg
					return BarChartDataEntry(x: Double(i), y: element)
				}
			let set = BarChartDataSet(values: yVals, label: "")
	
			set.drawIconsEnabled = false
			set.setColor(Style.shared.blue)
			
			let traceElements = samples.filter { (sample) -> Bool in
				return sample.value == 0
			}
			let traceNames = traceElements.map { (sample) -> String in
				return sample.type.name
			}
			let traceString = traceNames.reduce("") { (result, name) -> String in
				if result == ""{ return name }
				return result + ", " + name
			}
			if traceString.count > 0{
				traceLabel.text = "Traces of " + traceString
			} else{
				traceLabel.text = ""
			}

			
//		set.colors = [Style.shared.red, Style.shared.orange, Style.shared.blue, Style.shared.green]
//			set.colors = [Style.shared.green, Style.shared.blue, Style.shared.red, Style.shared.orange ]
//		set.stackLabels = speciesGroups.map({ $0.asString() })
//			set.stackLabels = [
//				ChartData.shared.pollenTypeGroups[3].asString(),
//				ChartData.shared.pollenTypeGroups[2].asString(),
//				ChartData.shared.pollenTypeGroups[0].asString(),
//				ChartData.shared.pollenTypeGroups[1].asString()
//			]

			let data = BarChartData(dataSet: set)
			data.barWidth = 0.8
			chartView.fitBars = false
			chartView.scaleYEnabled = false
			data.setDrawValues(false)
			chartView.data = data
			chartView.leftAxis.drawLabelsEnabled = false
			chartView.rightAxis.drawLabelsEnabled = false
			chartView.drawGridBackgroundEnabled = false
			
			chartView.xAxis.valueFormatter = self
			chartView.getAxis(.left).drawLabelsEnabled = false
			chartView.getAxis(.right).drawLabelsEnabled = false
			chartView.xAxis.drawGridLinesEnabled = false
			chartView.chartDescription?.enabled = false

			chartView.isUserInteractionEnabled = false
			chartView.dragEnabled = true
			chartView.setScaleEnabled(false)
			chartView.pinchZoomEnabled = false
			chartView.legend.enabled = false
			chartView.leftAxis.enabled = false
			chartView.leftAxis.spaceBottom = 0.0
			chartView.rightAxis.enabled = false
			chartView.xAxis.enabled = false
			chartView.doubleTapToZoomEnabled = false
			if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
				chartView.xAxis.labelFont = font
			}
			chartView.xAxis.enabled = true
//			chartView.xAxis.granularity = 30.0
			chartView.xAxis.granularity = 1.0
			chartView.xAxis.drawAxisLineEnabled = false
			chartView.xAxis.drawGridLinesEnabled = false
			chartView.xAxis.drawLabelsEnabled = true
			chartView.xAxis.labelPosition = .bottom
			if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15){
				chartView.noDataFont = font
			}

			chartView.getAxis(.left).drawGridLinesEnabled = true
			chartView.getAxis(.right).drawGridLinesEnabled = true
			chartView.getAxis(.left).granularity = 1
			chartView.getAxis(.right).granularity = 1
//			chartView.xAxis.axisMaximum = 0
			chartView.getAxis(.left).axisMinimum = 0
			chartView.getAxis(.right).axisMinimum = 0
			chartView.getAxis(.left).axisMaximum = 1
			chartView.getAxis(.right).axisMaximum = 1

			chartView.noDataText = "waiting on data.."
			chartView.drawBarShadowEnabled = false
			chartView.drawValueAboveBarEnabled = true
			chartView.maxVisibleCount = 60
			chartView.fitBars = false
			chartView.animate(yAxisDuration: 0.2)
		}
		
		self.setNeedsLayout()
		
	}
	
}

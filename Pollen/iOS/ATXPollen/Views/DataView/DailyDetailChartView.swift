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
	
	let watermarkView = UIView()
	let barLabelView = UIView()
	
	// charts
	let chartView = HorizontalBarChartView()
	var axisNames:[String]?
	var axisValues:[Double] = []
	var axisDegrees:[String] = []
	
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
		self.addSubview(watermarkView)
		self.addSubview(dateLabel)
		self.addSubview(dateUnderline)
		self.addSubview(bottomUnderline)
		self.addSubview(traceLabel)
		self.addSubview(chartView)
		self.addSubview(barLabelView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		watermarkView.frame = self.bounds
		dateLabel.sizeToFit()
		dateLabel.frame.origin = CGPoint(x: 20, y: 0)
		dateUnderline.frame = CGRect(x: 0, y: 0, width: dateLabel.frame.size.width, height: 1)
		dateUnderline.center = CGPoint(x: dateLabel.center.x, y: dateLabel.center.y + dateLabel.frame.size.height*0.5)
		bottomUnderline.frame = CGRect(x: dateUnderline.frame.origin.x, y: self.bounds.size.height, width: self.bounds.size.width - dateUnderline.frame.origin.x*2, height: 1)
		
		traceLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width-40, height: 200)
		traceLabel.sizeToFit()
		traceLabel.frame.origin = CGPoint(x: 20, y: self.bounds.size.height - traceLabel.frame.size.height)
		
		if let entries = chartView.data?.dataSets.first?.entryCount{
			chartView.frame = CGRect(x: 0, y: dateUnderline.frame.origin.y, width: self.bounds.size.width, height: self.bounds.size.height * 0.12 + self.bounds.size.height * 0.1 * CGFloat(entries))
		} else{
			chartView.frame = CGRect(x: 0, y: dateUnderline.frame.origin.y, width: self.bounds.size.width, height: self.bounds.size.height * 0.7)
		}
		
		if chartView.frame.size.height > self.bounds.size.height * 0.666 { chartView.frame.size.height = self.bounds.size.height * 0.666 }
		
		barLabelView.frame = chartView.frame
		
		guard let data = chartView.data else { return }
		
		let ratingLogData:[(String,Double)] = [
			(PollenRating.low.asString(), 0.177),
			(PollenRating.medium.asString(), 0.328),
			(PollenRating.heavy.asString(), 0.588),
			(PollenRating.veryHeavy.asString(), 1.0)
		]
		
		// vertical watermark lines
		watermarkView.subviews.forEach { (view) in
			view.removeFromSuperview()
		}
		let ratingXs = ratingLogData.map { (name, logValue) -> (String, CGFloat) in
			return (name, chartView.pixelForValues(x: logValue, y: 0.0, axis: .left).x)
		}
		ratingXs.forEach { (string, xLocation) in
			let v = UIView()
			v.frame = CGRect(x: xLocation, y: self.chartView.frame.origin.y, width: 1, height: self.chartView.frame.size.height)
			v.backgroundColor = .lightGray
			watermarkView.addSubview(v)
		}
		
		// pollen intensity labels on bars
		let rightPad:CGFloat = 3.0
		barLabelView.subviews.forEach { (view) in
			view.removeFromSuperview()
		}
		for i in 0..<data.dataSets[0].entryCount {
			if let entry = data.dataSets[0].entryForIndex(i) as? BarChartDataEntry{
				let barBounds = chartView.getBarBounds(entry: entry)
				let label = UILabel()
				label.textAlignment = .right
				label.text = axisDegrees[i]
				label.textColor = .white
				label.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P09)
				label.sizeToFit()
				label.center = CGPoint(x: barBounds.origin.x + barBounds.size.width - label.frame.size.width*0.5 - rightPad, y:barBounds.origin.y + barBounds.size.height*0.5)
				self.barLabelView.addSubview(label)
			}
		}
		
	}
	
	func reloadData(with date:Date?){
		dateLabel.text = ""
		
		guard let date = date else {return}
		
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
			axisDegrees = nonTraceSamples.map({ $0.rating.asString() })
			axisValues = nonTraceSamples
				.map({ Double($0.logValue) })
			let yVals = axisValues
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
			chartView.getAxis(.left).axisMinimum = 0
			chartView.getAxis(.right).axisMinimum = 0
			chartView.getAxis(.left).axisMaximum = 1
			chartView.getAxis(.right).axisMaximum = 1
			
			chartView.noDataText = "waiting on data.."
			chartView.drawBarShadowEnabled = false
			chartView.drawValueAboveBarEnabled = true
			chartView.maxVisibleCount = 60
			chartView.fitBars = false
			//			chartView.animate(yAxisDuration: 0.2)
		}
		
		self.setNeedsLayout()
		
	}
	
}

//
//  MyChartsView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 5/16/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
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


class MyChartsView: UIView, ChartViewDelegate {
	var allCharts:[LineChartView] = []

	let dateChart = LineChartView()
	let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
	let groupCharts = [LineChartView(), LineChartView(), LineChartView(), LineChartView()]
	let symptomCharts = [LineChartView(), ScatterChartView()]
	var clinicSampleData:[[PollenSamples]] = [[]]
	var lowBounds = Date()
	var upperBounds = Date()
	let detailTextView = UITextView()
	
	let months = ["Jan", "Feb", "Mar",
				  "Apr", "May", "Jun",
				  "Jul", "Aug", "Sep",
				  "Oct", "Nov", "Dec"]
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() { self.init(frame: CGRect.zero) }
	required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }
	
	func initUI(){
		lowBounds = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
		upperBounds = Date()

		self.addSubview(dateChart)
		groupCharts.forEach({
			self.addSubview($0)
			$0.delegate = self
		})
		symptomCharts.forEach({
			self.addSubview($0)
			$0.delegate = self
		})

		allCharts = [dateChart] + groupCharts + [symptomCharts[0] as! LineChartView]

		let groups = [PollenTypeGroup.grasses, PollenTypeGroup.weeds, PollenTypeGroup.trees, PollenTypeGroup.molds]
		for i in 0..<labels.count{
			labels[i].font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			labels[i].textColor = Style.shared.blue
			labels[i].text = groups[i].asString()
			labels[i].textAlignment = .left
			labels[i].sizeToFit()
			self.addSubview(labels[i])
		}
		
		detailTextView.textColor = Style.shared.blue
		detailTextView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.addSubview(detailTextView)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .pollenDidUpdate, object: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		dateChart.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 40)
		
		let marginTop:CGFloat = 50
		let h:CGFloat = self.bounds.size.height*0.1
		for i in 0..<groupCharts.count{
			groupCharts[i].frame = CGRect(x: 0, y: marginTop + h*CGFloat(i), width: self.bounds.size.width, height: h)
		}
		for i in 0..<labels.count{
			labels[i].center = CGPoint(x: 10 + labels[i].frame.size.width*0.5, y: marginTop + h*CGFloat(i) + labels[i].frame.size.height*0.5 - 5)
		}
		
		symptomCharts[0].frame = CGRect(x: 0, y: groupCharts.last!.frame.bottom, width: self.bounds.size.width, height: h)

		let chartBottom = symptomCharts[0].frame.bottom+20
		detailTextView.frame = CGRect(x: 20, y: chartBottom, width: self.frame.size.width-40, height: self.frame.size.height - chartBottom - 30 )
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
	}
	
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		let otherCharts = groupCharts.filter({ chartView != $0 })
		otherCharts.forEach { (chart) in
			var y:Double = 0
			if let data = chart.data{
				if let foundentry = data.dataSets[0].entriesForXValue(highlight.x).first{
					y = foundentry.y
				}
			}
			chart.highlightValue(x: highlight.x, y: y, dataSetIndex: highlight.dataSetIndex, dataIndex: highlight.dataIndex, callDelegate: false)
		}
		
		let speciesArray = [PollenTypeGroup.grasses, PollenTypeGroup.weeds, PollenTypeGroup.trees, PollenTypeGroup.molds]
		var detailString = ""
		if let date = clinicSampleData[0][Int(highlight.x)].date{
			let formatter = DateFormatter()
			formatter.dateFormat = "MMM d, yyyy"
			detailString += formatter.string(from: date) + "\n"
		}
		clinicSampleData
			.map { $0[Int(highlight.x)] }
			.enumerated()
			.forEach({
				if let strongest = $0.element.strongestSample(){
					detailString += "\(speciesArray[$0.offset].asString()): \(strongest.rating.asString()) (\(strongest.value))\n"
				}
			})
		detailTextView.text = detailString
	}

	@objc func reloadData(){
		let samples = ClinicData.shared.pollenSamples.filter({
			if let date = $0.date{ return date.isBetween(lowBounds, and: upperBounds) }
			return false
		})
		
		let dateArray = samples.compactMap({ $0.date }).sorted()
		
		let bySpecies = [PollenTypeGroup.grasses, PollenTypeGroup.weeds, PollenTypeGroup.trees, PollenTypeGroup.molds]
			.map { (group) -> [PollenSamples] in
				return samples
					.map({ $0.relevantToMyAllergies() })
					.map({ $0.filteredBy(group: group) })
		}
		let cal = Calendar.current
		clinicSampleData = bySpecies.map { (speciesSamples) -> [PollenSamples] in
			return dateArray.map { (date) -> PollenSamples in
				return speciesSamples.filter({
					guard let sampleDate = $0.date else { return false }
					return cal.isDate(sampleDate, inSameDayAs: date)
				}).first ?? PollenSamples(fromDatabase: [:])
			}
		}
		
		let symptomData = dateArray.map { (date) -> SymptomEntry in
			return Symptom.shared.entries.filter({
				let sampleDate = $0.date
				return cal.isDate(sampleDate, inSameDayAs: date)
			}).first ?? SymptomEntry(date: date, location: nil, rating: nil, exposures: nil)
		}
		
		let symptomChartData = symptomData.map { (entry) -> Double in
			if let rating = entry.rating{ return Double(rating.rawValue)/3 }
			return 0
			}
		print(symptomData)
		print(symptomChartData)
		setupFilledChart(symptomCharts[0] as! LineChartView, data: filledChartData(from: symptomChartData, color: Style.shared.blue), color: .white)

		clinicSampleData
			.map({ (samples) -> [Double] in
				return samples
					.map({ $0.strongestSample() ?? PollenSample(withKey: "nil", value: 0) })
					.map({ Double($0.logValue) })
			})
			.map({ return filledChartData(from: $0, color: Style.shared.green) })
			.enumerated()
			.forEach { (entry) in
				setupFilledChart(groupCharts[entry.offset], data: entry.element, color: .white)
		}
		
		setupDateChart(dateChart, data:dateChartData(from: dateArray, level:.day))
	}
	
	
	
	
	func setupFilledChart(_ chart: LineChartView, data: LineChartData, color: UIColor) {
		(data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = color
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



	
	
	
	func setupDateChart(_ chart: LineChartView, data: LineChartData) {
//		(data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = UIColor.white
//		chart.delegate = self
//		chart.backgroundColor = UIColor.white
//		chart.chartDescription?.enabled = false
//		chart.dragEnabled = true
//		chart.setScaleEnabled(true)
//		chart.pinchZoomEnabled = false
//		chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
//		chart.legend.enabled = false
//		chart.leftAxis.enabled = false
//		chart.leftAxis.spaceTop = 0.0
//		chart.leftAxis.spaceBottom = 0.0
//		chart.rightAxis.enabled = false
//		chart.xAxis.enabled = true
//		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12){
//			chart.xAxis.labelFont = font
//		}
		
//		chart.legend.wordWrapEnabled = true
//		chart.legend.horizontalAlignment = .center
//		chart.legend.verticalAlignment = .bottom
//		chart.legend.orientation = .horizontal
//		chart.legend.drawInside = false
//        chartView.legend = l
		
		chart.chartDescription?.text = ""
		
		chart.rightAxis.axisMinimum = 0
		chart.leftAxis.axisMinimum = 0
//		chart.xAxis.labelPosition = .bothSided
		chart.xAxis.axisMinimum = 0
		chart.xAxis.granularity = 1
		chart.xAxis.valueFormatter = self
		chart.xAxis.axisMaximum = data.xMax + 0.25
		chart.data = data

//		chart.doubleTapToZoomEnabled = false
//		chart.animate(xAxisDuration: 0.5)
	}

	func dateChartData(from array:[Date], level:Calendar.Component) -> LineChartData {
//		let values = array.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: 0, data: $0.element as AnyObject) })
//		let dateSet = LineChartDataSet(values: values, label: "Dates")

		let entries = (0..<array.count).map { (i) -> ChartDataEntry in
			return ChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
		}
		
		let set = LineChartDataSet(values: entries, label: "Dates")
		set.setColor(UIColor.clear)
		set.lineWidth = 2.5
		set.setCircleColor(UIColor.clear)
		set.circleRadius = 5
		set.circleHoleRadius = 2.5
		set.fillColor = UIColor.clear
//		set.mode = .cubicBezier
		set.drawValuesEnabled = true
//		set.valueFont = .systemFont(ofSize: 10)
		if let font = UIFont(name: SYSTEM_FONT, size: Style.shared.P11){
			set.valueFont = font
		}
		set.valueTextColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
		
		set.axisDependency = .left
		
		return LineChartData(dataSet: set)
	}
}


extension MyChartsView: IAxisValueFormatter {
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		return months[Int(value) % months.count]
	}
}

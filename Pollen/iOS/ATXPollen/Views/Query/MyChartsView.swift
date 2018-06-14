//
//  MyChartsView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 5/16/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts


class MyChartsView: UIView, ChartViewDelegate {
	
	// parameters for data
	let speciesGroups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]
	let exposureTypes:[Exposures] = [.dog, .cat, .dust, .molds, .virus]
	var lowBounds = Date()
	var upperBounds = Date()
	
	var dataDates:[Date] = []

	// data visualized
	var clinicSampleData:[[PollenSamples]] = [[]]
	var clinicSampleLogValues:[[Double]] = [[]]
	var symptomEntryData:[SymptomEntry] = []
	var allergyDataValues:[Double] = []
	var exposureEntryData:[[Bool]] = []
	
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
		
		lowBounds = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
		upperBounds = Date()

		allCharts = [dateChart] + groupCharts + symptomCharts
		allCharts.forEach({
			self.addSubview($0)
			$0.delegate = self
		})
		
		chartLabels.enumerated().forEach({
			$0.element.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			$0.element.textColor = .black
			$0.element.text = speciesGroups[$0.offset].asString()
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
	
//	func reloadData(){
//		
//	}
	
	func reloadData(){
		
		// get array of Clinic Sample data between dates lowBounds and upperBounds
		// this filter function validates all dates exist, so we can use ! from now on.
		let clinicData = ClinicData.shared.pollenSamples.filter({
			if let date = $0.date{ return date.isBetween(lowBounds, and: upperBounds) }
			return false
		}).sorted(by: { $0.date! < $1.date! })
		dataDates = clinicData.map({ $0.date! })
		// for every species type in [speciesGroups], create a inner array of all filtered clinicData
		// creating [[PollenSamples],[PollenSamples],[PollenSamples],[PollenSamples]]
		let clinicDataBySpecies = speciesGroups
			.map { (group) -> [PollenSamples] in
				return clinicData
					.map({ $0.relevantToMyAllergies() })
					.map({ $0.filteredBy(group: group) })
		}
		// convert [[PollenSamples],[PollenSamples],[PollenSamples],[PollenSamples]]
		// into    [[PollenSamples],[PollenSamples],[PollenSamples],[PollenSamples]]
		// but that each inner array is length 1:1 mapped to dates inside clinicData
		// empty PollenSamples are generated to sit in Dates that had no PollenSample
		let cal = Calendar.current
		clinicSampleData = clinicDataBySpecies.map { (speciesSamples) -> [PollenSamples] in
			return clinicData.map({ $0.date! }).map { (date) -> PollenSamples in
				return speciesSamples.filter({
					guard let sampleDate = $0.date else { return false }
					return cal.isDate(sampleDate, inSameDayAs: date)
				}).first ?? PollenSamples(fromDatabase: [:])
			}
		}
		// [[Double],[Double],[Double],[Double]], each species group array of log values, strongest daily sample
		clinicSampleLogValues = clinicSampleData
			.map({ (samples) -> [Double] in
				return samples.map({ let ss = $0.strongestSample(); return (ss != nil) ? Double(ss!.logValue) : 0.0 })
			})

		// SYMPTOMS (ALLERGIES AND EXPOSURES)
		// generate array of symptom data 1:1 for every day, empty SymptomEntry for dates with no prior data
		symptomEntryData = clinicData.map({ $0.date! }).map { (date) -> SymptomEntry in
			return Symptom.shared.entries.filter({ return cal.isDate($0.date, inSameDayAs: date) }).first ??
				SymptomEntry(date: date, location: nil, rating: nil, exposures: nil)
		}
		// ALLERGIES
		allergyDataValues = symptomEntryData.map({ $0.rating != nil ? Double($0.rating!.rawValue)/3 : 0 })
		// EXPOSURES
		// for each day [[Bool],[Bool],[Bool],[Bool],[Bool]] for each exposureType
		let exposureChartData = symptomEntryData
			.map({ $0.exposures != nil ? $0.exposures! : [] })
			.map { (exposure) -> [Bool] in return exposureTypes.map({ exposure.contains($0) }) }
		// row column flip
		// instead of array with length ~ 365 each containing inner arrays length 5
		// convert into 5 arrays, each containing array of length 365
		exposureEntryData = exposureTypes.map { (exposure) -> [Bool] in
			return exposureChartData.map({ (boolArray) -> Bool in
				return boolArray[exposure.rawValue]
			})
		}

		setupDateChart(dateChart, data:dateChartData(from: clinicData.map({ $0.date! }), level:.day))
		clinicSampleData
			.map({ return barChartData(from: $0) })
			.enumerated()
			.forEach({ setupBarChart(groupCharts[$0.offset] as! BarChartView, data: $0.element) })
		setupFilledChart(symptomCharts[0] as! LineChartView, data: filledChartData(from: allergyDataValues))
		setupScatterChart(symptomCharts[1] as! ScatterChartView, data: scatterData(from: exposureEntryData))
		
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
		self.chartLabels.enumerated().forEach({ $0.element.text = speciesGroups[$0.offset].asString() })
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
		self.chartLabels.enumerated().forEach({ $0.element.text = speciesGroups[$0.offset].asString() })
		// deta
		clinicSampleData
			.map { $0[Int(highlight.x)] }
			.enumerated()
			.forEach({
				if let strongest = $0.element.strongestSample(){
					self.chartLabels[$0.offset].text = "\(speciesGroups[$0.offset].asString()): \(strongest.rating.asString()) (\(strongest.value))"
				}
			})
		self.chartLabels.forEach({ $0.sizeToFit() })
	}

}

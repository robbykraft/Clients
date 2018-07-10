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
	}
}

class StackedChartView: UIView, ChartViewDelegate {

	// parameters for data
	let speciesGroups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]
	let exposureTypes:[Exposures] = [.dog, .cat, .dust, .molds, .virus]
	var lowBounds = Date()
	var upperBounds = Date()
	
	var dataDates:[Date] = []
	
	// data visualized
	var clinicSampleData:[[DailyPollenCount]] = [[]]
	var symptomEntryData:[SymptomEntry] = []
	var allergyDataValues:[Double] = []
	var exposureEntryData:[[Bool]] = []
	
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
		lowBounds = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
		upperBounds = Date()
		
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
		// get array of Clinic Sample data between dates lowBounds and upperBounds
		// this filter function validates all dates exist, so we can use ! from now on.
		let clinicData = ClinicData.shared.dailyCounts.filter({
			if let date = $0.date{ return date.isBetween(lowBounds, and: upperBounds) }
			return false
		}).sorted(by: { $0.date! < $1.date! })
		// if no data, return
		if clinicData.count == 0{ return }
		dataDates = clinicData.map({ $0.date! })
		
		// for every species type in [speciesGroups], create a inner array of all filtered clinicData
		// creating [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		let clinicDataBySpecies = speciesGroups
			.map { (group) -> [DailyPollenCount] in
				return clinicData
					.map({ $0.relevantToMyAllergies() })
					.map({ $0.filteredBy(group: group) })
		}
		// convert [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		// into    [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		// but that each inner array is length 1:1 mapped to dates inside clinicData
		// empty DailyPollenCount are generated to sit in Dates that had no PollenSample
		let cal = Calendar.current
		clinicSampleData = clinicDataBySpecies.map { (speciesSamples) -> [DailyPollenCount] in
			return clinicData.map({ $0.date! }).map { (date) -> DailyPollenCount in
				return speciesSamples.filter({
					guard let sampleDate = $0.date else { return false }
					return cal.isDate(sampleDate, inSameDayAs: date)
				}).first ?? DailyPollenCount(fromDatabase: [:])
			}
		}
		
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
		
		let stackedData = clinicSampleData.map { (samples:[DailyPollenCount]) -> [Double] in
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
			speciesGroups[3].asString(),
			speciesGroups[2].asString(),
			speciesGroups[0].asString(),
			speciesGroups[1].asString()
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

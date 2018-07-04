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

	// parameters for data
	let speciesGroups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]
	let exposureTypes:[Exposures] = [.dog, .cat, .dust, .molds, .virus]
	var lowBounds = Date()
	var upperBounds = Date()
	
	var clinicDataDates:[Date] = []
	
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
		clinicDataDates = clinicData.map({ $0.date! })
		
		let months = Array((0..<12).reversed()).map { (i) -> Date in
			var minusMonth = DateComponents()
			minusMonth.month = -i
			return Calendar.current.date(byAdding: minusMonth, to: Date())!
		}
		
		let clinicDataMonthly = months.map { (date) -> [DailyPollenCount] in
			return clinicData.filter({ (samples:DailyPollenCount) -> Bool in
				return Calendar.current.isDate(samples.date!, equalTo: date, toGranularity: .month)
			})
		}
		
//		print(clinicDataMonthly)
		
		let clinicDataAverageMonthly = clinicDataMonthly.map { (array:[DailyPollenCount]) -> DailyPollenCount in
			return averageDailyPollenCounts(dailies: array)
		}

//		print("clinicDataAverageMonthly")
//		print(clinicDataAverageMonthly)
		
//		print("strongest")
//		clinicDataAverageMonthly.forEach { (count) in
//			print(count.strongestSample())
//		}
		
		let groupsDataAverageMonthly = speciesGroups.map({ (group) -> [PollenSample] in
			return clinicDataAverageMonthly.map({ (daily:DailyPollenCount) -> PollenSample in
				return daily.strongestSample(of: group) ?? PollenSample(withKey: "nil", value: 0)
			})
		})

		
//		let clinicDataMonthly =
		
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
		
		let groupSpace = 0.08
		let barSpace = 0.00
		let barWidth = 0.23
		// (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"
		
		let yVals = groupsDataAverageMonthly.map { (sampleArray) -> [Double] in
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
		
		let set1 = BarChartDataSet(values: yVals[0], label: speciesGroups[0].asString())
		let set2 = BarChartDataSet(values: yVals[1], label: speciesGroups[1].asString())
		let set3 = BarChartDataSet(values: yVals[2], label: speciesGroups[2].asString())
		let set4 = BarChartDataSet(values: yVals[3], label: speciesGroups[3].asString())

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

		// restrict the x-axis range
//		chartView.xAxis.axisMinimum = Double(startYear)
		
		// groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
//		chartView.xAxis.axisMaximum = Double(startYear) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
		
//		data.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
		
	}
		
//		let stackedData = clinicSampleData.map { (samples:[DailyPollenCount]) -> [Double] in
//			return samples.map({ (s:DailyPollenCount) -> Double in
//				let ss = s.strongestSample()
//				return (ss != nil) ? Double(ss!.logValue) : Double(0.0)
//			})
//		}
		
//		let innerCount = stackedData[0].count
//		var yVals:[BarChartDataEntry] = []
//		for i in 0..<innerCount{
//			let column = [ stackedData[3][i], stackedData[2][i], stackedData[0][i], stackedData[1][i] ]
//			yVals.append(BarChartDataEntry(x: Double(i), yValues: column))
//		}
//		let set = BarChartDataSet(values: yVals, label: "Stacked Clinic Data")
//		set.drawIconsEnabled = false
//		//		set.colors = [Style.shared.red, Style.shared.orange, Style.shared.blue, Style.shared.green]
//		set.colors = [Style.shared.green, Style.shared.blue, Style.shared.red, Style.shared.orange ]
//		//		set.stackLabels = speciesGroups.map({ $0.asString() })
//		set.stackLabels = [
//			speciesGroups[3].asString(),
//			speciesGroups[2].asString(),
//			speciesGroups[0].asString(),
//			speciesGroups[1].asString()
//		]
//		let data = BarChartData(dataSet: set)
//		chartView.fitBars = true
//		chartView.scaleYEnabled = false
//		data.setDrawValues(false)
//		chartView.data = data
//		chartView.leftAxis.drawLabelsEnabled = false
//		chartView.rightAxis.drawLabelsEnabled = false
//		chartView.drawGridBackgroundEnabled = false
//
//		chartView.xAxis.valueFormatter = self
		
		
		
		
		//		clinicSampleData
		//			.map({ return barChartData(from: $0) })
		//			.enumerated()
		//			.forEach({ setupBarChart(groupCharts[$0.offset] as! BarChartView, data: $0.element) })
		//		setupFilledChart(symptomCharts[0] as! LineChartView, data: filledChartData(from: allergyDataValues))
		//		setupScatterChart(symptomCharts[1] as! ScatterChartView, data: scatterData(from: exposureEntryData))
		
		// reset views
		//		allCharts.forEach { (chart) in
		//			chart.zoom(scaleX: 2, scaleY: 1, x: chart.frame.size.width*1.5, y: 0)
		//		}
		//		zoomPage = 1
		//		dateChart.xAxis.granularity = 1.0


	
	//	override func updateChartData() {
	//		if self.shouldHideData {
	//			chartView.data = nil
	//			return
	//		}
	//
	//		self.setChartData(count: Int(sliderX.value + 1), range: UInt32(sliderY.value))
	//	}
	
	//	func setChartData(count: Int, range: UInt32) {
	//		let yVals = (0..<count).map { (i) -> BarChartDataEntry in
	//			let mult = range + 1
	//			let val1 = Double(arc4random_uniform(mult) + mult / 3)
	//			let val2 = Double(arc4random_uniform(mult) + mult / 3)
	//			let val3 = Double(arc4random_uniform(mult) + mult / 3)
	//
	//			return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3], icon: #imageLiteral(resourceName: "icon"))
	//		}
	//
	//		let set = BarChartDataSet(values: yVals, label: "Statistics Vienna 2014")
	//		set.drawIconsEnabled = false
	//		set.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[1], ChartColorTemplates.material()[2]]
	//		set.stackLabels = ["Births", "Divorces", "Marriages"]
	//
	//		let data = BarChartData(dataSet: set)
	//		data.setValueFont(.systemFont(ofSize: 7, weight: .light))
	//		data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
	//		data.setValueTextColor(.white)
	//
	//		chartView.fitBars = true
	//		chartView.data = data
	//	}
	
	
	//	func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
	//		let otherCharts = allCharts.filter({ chartView != $0 })
	//		otherCharts.forEach { (chart) in
	//			chart.viewPortHandler.refresh(newMatrix: chartView.viewPortHandler.touchMatrix, chart: chart, invalidate: false)
	//		}
	//	}
	//	func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
	//		let otherCharts = allCharts.filter({ chartView != $0 })
	//		otherCharts.forEach { (chart) in
	//			chart.viewPortHandler.refresh(newMatrix: chartView.viewPortHandler.touchMatrix, chart: chart, invalidate: false)
	//		}
	//		if let chart = otherCharts.first{
	//			zoomPage = (chart.viewPortHandler.scaleX < 4) ? 0 : 1
	//		}
	//	}
	
	//	func chartValueNothingSelected(_ chartView: ChartViewBase) {
	//		allCharts
	//			.filter({ chartView != $0 })
	//			.filter({ $0 != dateChart })
	//			.forEach { (chart) in
	//				chart.highlightValue(x: -1, dataSetIndex: 1, callDelegate: false)
	//		}
	//		self.chartLabels.enumerated().forEach({ $0.element.text = speciesGroups[$0.offset].asString() })
	//	}
	
	//	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
	//		allCharts
	//			.filter({ chartView != $0 })
	//			.filter({ $0 != dateChart })
	//			.forEach { (chart) in
	//				var y:Double = 0
	//				if let data = chart.data{
	//					if let foundentry = data.dataSets[0].entriesForXValue(highlight.x).first{
	//						y = foundentry.y
	//					}
	//				}
	//				chart.highlightValue(x: highlight.x, y: y, dataSetIndex: highlight.dataSetIndex, dataIndex: highlight.dataIndex, callDelegate: false)
	//		}
	//		// clear out entry
	//		self.chartLabels.enumerated().forEach({ $0.element.text = speciesGroups[$0.offset].asString() })
	//		// deta
	//		clinicSampleData
	//			.map { $0[Int(highlight.x)] }
	//			.enumerated()
	//			.forEach({
	//				if let strongest = $0.element.strongestSample(){
	//					self.chartLabels[$0.offset].text = "\(speciesGroups[$0.offset].asString()): \(strongest.rating.asString()) (\(strongest.value))"
	//				}
	//			})
	//		self.chartLabels.forEach({ $0.sizeToFit() })
	//	}
	
}

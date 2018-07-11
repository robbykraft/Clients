//
//  MonthlyDetailBarChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/3/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

extension MonthlyDetailBarChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {

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

class MonthlyDetailBarChartView: UIView, ChartViewDelegate {
	
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
		if ChartData.shared.clinicDataYearDates.count == 0{ return}

		
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
	
	}
}


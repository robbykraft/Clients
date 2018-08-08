//
//  ChartData.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts

extension Notification.Name {
	static let chartDataDidUpdate = Notification.Name("CHART_DATA_DID_UPDATE")
}

class ChartData{
	
	static let shared = ChartData()
	
	var clinicDataYearDates:[Date] = []
	var pastYearMonths:[Date] = []

	let pollenTypeGroups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]
	let exposureTypes:[Exposures] = [.dog, .cat, .dust, .molds, .virus]

	// data from past year
	var dailyClinicData:[DailyPollenCount] = []
	var monthlyClinicData:[DailyPollenCount] = []

	var dailyClinicDataByGroups:[[DailyPollenCount]] = [[]]
	var monthlyClinicDataByGroups:[[DailyPollenCount]] = [[]]

	var dailyStrongestSampleByGroups:[[PollenSample]] = [[]]
	var monthlyStrongestSampleByGroups:[[PollenSample]] = [[]]

	var dailySymptomData:[SymptomEntry] = []
	var allergyDataValues:[Double] = []
	var exposureDataValues:[[Bool]] = []

	fileprivate init(){
		reloadData()
	}
	
	func reloadData(){
		// all data is between one year ago and today
		let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
		let nowDate = Date()
		
		dailyClinicData = ClinicData.shared.dailyCounts.filter({
			if let date = $0.date{ return date.isBetween(yearAgo, and: nowDate) }
			return false
		}).sorted(by: { $0.date! < $1.date! })
		// do we make this relevant to my allergies?
//		.map({ $0.relevantToMyAllergies() })

		
		// convert [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		// into    [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		// but that each inner array is length 1:1 mapped to dates inside clinicData
		// empty DailyPollenCount are generated to sit in Dates that had no PollenSample
//		dailyClinicData = clinicDataBySpecies.map { (speciesSamples) -> [DailyPollenCount] in
//			return clinicData.map({ $0.date! }).map { (date) -> DailyPollenCount in
//				return speciesSamples.filter({
//					guard let sampleDate = $0.date else { return false }
//					return Calendar.current.isDate(sampleDate, inSameDayAs: date)
//				}).first ?? DailyPollenCount(fromDatabase: [:])
//			}
//		}

		
		// if no data, return
		if dailyClinicData.count == 0{ return }

		// array of daily dates for past year
		clinicDataYearDates = dailyClinicData.map({ $0.date! })

		// array of 12 dates, one for each month
		pastYearMonths = Array((0..<12).reversed()).map { (i) -> Date in
			var minusMonth = DateComponents()
			minusMonth.month = -i
			return Calendar.current.date(byAdding: minusMonth, to: Date())!
		}
		
		let monthlyClinicData = pastYearMonths.map { (date) -> [DailyPollenCount] in
			return dailyClinicData.filter({ (samples:DailyPollenCount) -> Bool in
				if let sDate = samples.date{ return Calendar.current.isDate(sDate, equalTo: date, toGranularity: .month) }
				return false
			})
			}.map { (array:[DailyPollenCount]) -> DailyPollenCount in
				return averageDailyPollenCounts(dailies: array)
			}

		// for every species type in [speciesGroups], create a inner array of all filtered clinicData
		// creating [[DailyPollenCount],[DailyPollenCount],[DailyPollenCount],[DailyPollenCount]]
		dailyClinicDataByGroups = pollenTypeGroups
			.map { (group) -> [DailyPollenCount] in
				return dailyClinicData
					.map({ $0.filteredBy(group: group) })
		}
		monthlyClinicDataByGroups = pollenTypeGroups
			.map { (group) -> [DailyPollenCount] in
				return monthlyClinicData
					.map({ $0.filteredBy(group: group) })
		}

		dailyStrongestSampleByGroups = dailyClinicDataByGroups.map { (dailyPollenCountArray) -> [PollenSample] in
			return dailyPollenCountArray.map({ (dailyPollenCount) -> PollenSample in
				return dailyPollenCount.strongestSample() ?? PollenSample(withKey: "nil", value: 0)
			})
		}
		monthlyStrongestSampleByGroups = monthlyClinicDataByGroups.map { (monthlyPollenCountArray) -> [PollenSample] in
			return monthlyPollenCountArray.map({ (monthlyPollenCount) -> PollenSample in
				return monthlyPollenCount.strongestSample() ?? PollenSample(withKey: "nil", value: 0)
			})
		}
		
		// SYMPTOMS (ALLERGIES AND EXPOSURES)
		// generate array of symptom data 1:1 for every day, empty SymptomEntry for dates with no prior data
		dailySymptomData = dailyClinicData.map({ $0.date! }).map { (date) -> SymptomEntry in
			return Symptom.shared.entries.filter({ return Calendar.current.isDate($0.date, inSameDayAs: date) }).first ??
				SymptomEntry(date: date, location: nil, rating: nil, exposures: nil)
		}
		// ALLERGIES
		allergyDataValues = dailySymptomData.map({ $0.rating != nil ? Double($0.rating!.rawValue)/3 : 0 })
		// EXPOSURES
		// for each day [[Bool],[Bool],[Bool],[Bool],[Bool]] for each exposureType
		let exposureChartData = dailySymptomData
			.map({ $0.exposures != nil ? $0.exposures! : [] })
			.map { (exposure) -> [Bool] in return exposureTypes.map({ exposure.contains($0) }) }
		// row column flip
		// instead of array with length ~ 365 each containing inner arrays length 5
		// convert into 5 arrays, each containing array of length 365
		exposureDataValues = exposureTypes.map { (exposure) -> [Bool] in
			return exposureChartData.map({ (boolArray) -> Bool in
				return boolArray[exposure.rawValue]
			})
		}
		
		NotificationCenter.default.post(name: .chartDataDidUpdate, object: nil)
	}
	
	func dailyClinicDataBarChartData() -> BarChartData{
		let logValues = dailyClinicData
			.map({ (sample) -> Double in
				let ss = sample.strongestSample();
				return (ss != nil) ? Double(ss!.logValue) : 0.0
			})
//			.map({ (sample:DailyPollenCount) -> Double in
//				// flatten values to integers
//				switch sample.rating(){
//				case .none: return 0.0
//				case .low: return 0.25
//				case .medium: return 0.5
//				case .heavy: return 0.75
//				case .veryHeavy: return 1.0
//				}
//			})
			.enumerated()
			.map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
//		let colors = dailyClinicData.map({ Style.shared.colorFor(rating: $0.rating()) })
		let set1 = BarChartDataSet(values: logValues, label: nil)
//		set1.setColors(colors, alpha: 1.0)
		set1.setColor(Style.shared.green)
		set1.highlightEnabled = true
		set1.highlightColor = Style.shared.orange
		set1.highlightAlpha = 1.0
		set1.drawValuesEnabled = false
		let chartData = BarChartData(dataSet: set1)
		chartData.barWidth = 1.01
		return chartData
	}
	
	
	func dailyClinicDataLineChartData() -> LineChartData{
		let logValues = dailyClinicData
			.map({ (sample) -> Double in
				let ss = sample.strongestSample();
				return (ss != nil) ? Double(ss!.logValue) : 0.0
			})
			.enumerated()
			.map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })

		let set = LineChartDataSet(values: logValues, label: nil)
//		set.setColor(Style.shared.green)
		set.setColor(UIColor(white: 0.75, alpha: 1.0))
		set.highlightEnabled = true
//		set.highlightColor = Style.shared.orange
//		set.highlightAlpha = 1.0
		set.drawValuesEnabled = false
		set.drawValuesEnabled = false
		set.drawFilledEnabled = true
		set.drawCirclesEnabled = false
		set.drawCircleHoleEnabled = false
//		set.setColor(UIColor.white)
		set.fillColor = UIColor(white: 0.75, alpha: 1.0)
		
		set.cubicIntensity = 0.2
		set.mode = .cubicBezier
		let chartData = LineChartData(dataSet: set)
		return chartData
	}
	func dailyClinicDataByGroupsBarChartData() -> [BarChartData]{
		let logValues = dailyClinicDataByGroups
			.map({ (dailyPollenCount) -> [Double] in
				return dailyPollenCount.map({ (sample) -> Double in
					let ss = sample.strongestSample();
					return (ss != nil) ? Double(ss!.logValue) : 0.0
				})
			})
//			.map({ (sample) -> Double in
//				let ss = sample.strongestSample();
//				return (ss != nil) ? Double(ss!.logValue) : 0.0
//			})
//			.map({ (sample:DailyPollenCount) -> Double in
//				// flatten values to integers
//				switch sample.rating(){
//				case .none: return 0.0
//				case .low: return 0.25
//				case .medium: return 0.5
//				case .heavy: return 0.75
//				case .veryHeavy: return 1.0
//				}
//			})
			.map({ (doubleArray) -> [BarChartDataEntry] in
				return doubleArray.enumerated().map({ (offset, entry) -> BarChartDataEntry in
					return BarChartDataEntry(x: Double(offset), y: entry)
				})
			})
//			.enumerated()
//			.map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
//		let colors = dailyClinicData.map({ Style.shared.colorFor(rating: $0.rating()) })
		let sets = logValues.map { (chartDataEntry) -> BarChartData in
			let set = BarChartDataSet(values: chartDataEntry, label: nil)
//			set.setColors(colors, alpha: 1.0)
			set.setColor(Style.shared.green)
			set.highlightEnabled = true
			set.highlightColor = Style.shared.orange
			set.highlightAlpha = 1.0
			set.drawValuesEnabled = false
			let chartData = BarChartData(dataSet: set)
			chartData.barWidth = 1.01
			return chartData
		}
		return sets
	}

	func dailyClinicDataByGroupsLineChartData() -> [LineChartData]{
		let logValues = dailyClinicDataByGroups
			.map({ (dailyPollenCount) -> [Double] in
				return dailyPollenCount.map({ (sample) -> Double in
					let ss = sample.strongestSample();
					return (ss != nil) ? Double(ss!.logValue) : 0.0
				})
			})
			.map({ (doubleArray) -> [BarChartDataEntry] in
				return doubleArray.enumerated().map({ (offset, entry) -> BarChartDataEntry in
					return BarChartDataEntry(x: Double(offset), y: entry)
				})
			})
		let sets = logValues.map { (chartDataEntry) -> LineChartData in
			let set = LineChartDataSet(values: chartDataEntry, label: nil)
//			set.setColors(colors, alpha: 1.0)
//			set.setColor(Style.shared.green)
			set.setColor(UIColor.init(white: 0.85, alpha: 1.0))
			set.highlightEnabled = true
			set.highlightColor = Style.shared.orange
//			set.highlightAlpha = 1.0
			set.drawValuesEnabled = false
			set.drawFilledEnabled = true
			set.drawCirclesEnabled = false
			set.drawCircleHoleEnabled = false
//			set.circleRadius = 6.0
			set.setColor(UIColor.white)
			set.cubicIntensity = 0.2
			set.mode = .cubicBezier
			let chartData = LineChartData(dataSet: set)
//			chartData.barWidth = 1.01
			
			return chartData
		}
		return sets
	}
	
	func dailyAllergyDataBarChartData() -> BarChartData{
		let values = allergyDataValues
			.map({ (value) -> Double in
				return 0.1 + 0.4 * value
			})
			.enumerated().map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
		
//		let rightSplit = values[146 ..< values.count]
		
//		let set = BarChartDataSet(values: Array(rightSplit), label: nil)
		let set = BarChartDataSet(values: values, label: nil)
//		set.lineWidth = 3.0
		set.highlightColor = Style.shared.blue
		set.highlightAlpha = 1.0
		set.highlightLineWidth = 2.0
		set.drawValuesEnabled = false
//		set.drawCirclesEnabled = true
//		set.drawCircleHoleEnabled = false
//		set.circleRadius = 6.0
		set.setColor(UIColor.white)
		
//		set.cubicIntensity = 0.2
		set.colors =
//		set.valueColors =
			allergyDataValues.map({
				//				if $0 == 0{ return UIColor.clear }
				if $0 == 0{ return UIColor.clear }
				if $0 < 0.5{ return Style.shared.yellow }
				if $0 < 0.75{ return Style.shared.orange }
				return Style.shared.red
			})
		return BarChartData(dataSet: set)
	}
	
	
	func dailyAllergyDataLineChart() -> LineChartData{
		let values = allergyDataValues
			.map({ (value) -> Double in
				return 0.1 + 0.4 * value
			})
			.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
		
		let rightSplit = values[146 ..< values.count]
		
		let set = LineChartDataSet(values: Array(rightSplit), label: nil)
		set.lineWidth = 3.0
		set.highlightColor = Style.shared.orange
		set.highlightLineWidth = 2.0
		set.drawValuesEnabled = false
		set.drawCirclesEnabled = true
		set.drawCircleHoleEnabled = false
		set.circleRadius = 6.0
		set.setColor(UIColor.white)
		set.cubicIntensity = 0.2
		set.valueColors =
			allergyDataValues.map({
//				if $0 == 0{ return UIColor.clear }
				if $0 == 0{ return UIColor.blue }
				if $0 < 0.5{ return Style.shared.orange }
				if $0 < 0.75{ return Style.shared.red }
				return Style.shared.purple
			})
		set.circleColors =
			allergyDataValues.map({
				if $0 == 0{ return UIColor.clear }
//				if $0 == 0{ return UIColor.blue }
				if $0 < 0.5{ return Style.shared.orange }
				if $0 < 0.75{ return Style.shared.red }
				return Style.shared.purple
			})
		set.drawFilledEnabled = false
		set.fillAlpha = 1
		set.mode = .cubicBezier
		return LineChartData(dataSet: set)
	}
	
	func dailyAllergyDataFilledLineChart() -> LineChartData {
		let values = allergyDataValues.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
		let set1 = LineChartDataSet(values: values, label: nil)
		set1.lineWidth = 0.1
		set1.highlightColor = Style.shared.orange
		set1.highlightLineWidth = 1
		set1.drawValuesEnabled = false
		set1.drawCirclesEnabled = false
		set1.drawFilledEnabled = true
		set1.fillAlpha = 1
		set1.fillColor = Style.shared.blue
//		set1.cubicIntensity = 0.5
		set1.mode = .cubicBezier
		return LineChartData(dataSet: set1)
	}

	func scatterData(from array:[[Bool]]) -> ScatterChartData{
		let colors = [Style.shared.orange, Style.shared.lightBlue, Style.shared.purple, Style.shared.softBlue, Style.shared.red]
		let dataSets = array.enumerated().map { (i, valueArray) -> ChartDataSet in
			let values = valueArray.map{ return $0 ? i+1 : 0
				}.enumerated().map({ (j, value) -> ChartDataEntry in
					return ChartDataEntry(x: Double(j), y: Double(value)/6)
				}).filter({ $0.y != 0.0 })
			let set = ScatterChartDataSet(values: values + [ChartDataEntry(x: 0, y: 0)], label: exposureTypes[i].asString())
			set.setScatterShape(.circle)
			set.scatterShapeHoleColor = colors[i%5]
			set.scatterShapeHoleRadius = 3.5
			set.drawValuesEnabled = false
			set.setColor(colors[i%5])
			set.scatterShapeSize = 8
			return set
		}
		return ScatterChartData(dataSets: dataSets)
	}
	
}
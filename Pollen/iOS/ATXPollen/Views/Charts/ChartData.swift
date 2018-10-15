//
//  ChartData.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import Foundation
import Charts


class ChartData{
	
	static let shared = ChartData()
	
	var clinicDataYearDates:[Date] = []
	var pastYearMonths:[Date] = []

	let pollenTypeGroups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]
//	let pollenTypeGroups:[PollenTypeGroup] = [.trees, .grasses, .molds, .weeds]

	let exposureTypes:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})

	// data from past year
	var dailyClinicData:[DailyPollenCount] = []
	var monthlyClinicData:[DailyPollenCount] = []

	var dailyClinicDataByGroups:[[DailyPollenCount]] = [[]]
	var monthlyClinicDataByGroups:[[DailyPollenCount]] = [[]]

	var dailyStrongestSampleByGroups:[[PollenSample]] = [[]]
	var monthlyStrongestSampleByGroups:[[PollenSample]] = [[]]

	var dailySymptomData:[SymptomEntry] = []
	var allergyDataValues:[Int?] = []
	var exposureDailyData:[[Bool]] = []
	var exposureDataByTypes:[[Bool]] = []

	func yearlyIndex(for date:Date) -> Int?{
		// find the matching day in ChartData index
		if clinicDataYearDates.count == 0{ return nil }
		for i in 0..<clinicDataYearDates.count{
			if Calendar.current.isDate(clinicDataYearDates[i], inSameDayAs: date){
				return i
			}
		}
		return nil
	}

	fileprivate init(){
		reloadData()
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .pollenDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .symptomDidUpdate, object: nil)
	}
	
	@objc func reloadData(){
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
		allergyDataValues = dailySymptomData.map({ $0.rating != nil ? $0.rating!.rawValue : nil })
		// EXPOSURES
		// for each day [[Bool],[Bool],[Bool],[Bool],[Bool]] for each exposureType
		exposureDailyData = dailySymptomData
			.map({ $0.exposures != nil ? $0.exposures! : [] })
			.map { (exposure) -> [Bool] in return exposureTypes.map({ exposure.contains($0) }) }
		// row column flip
		// instead of array with length ~ 365 each containing inner arrays length 5
		// convert into 5 arrays, each containing array of length 365
		exposureDataByTypes = exposureTypes.map { (exposure) -> [Bool] in
			return exposureDailyData.map({ (boolArray) -> Bool in
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
		set1.highlightColor = Style.shared.blue
		set1.highlightAlpha = 1.0
		set1.highlightLineWidth = 5.0
		set1.drawValuesEnabled = false
		let chartData = BarChartData(dataSet: set1)
		chartData.barWidth = 1.01
		return chartData
	}
	
	
	func dailyClinicDataLineChartData() -> LineChartData{
		let logValues = dailyClinicData
			.map({ (sample) -> Double in
				let ss = sample.strongestSample();
//				if let rating = ss?.rating{
//				switch rating{
//				case PollenRating.none: return 0
//				case PollenRating.low: return 0.25
//				case PollenRating.medium: return 0.5
//				case PollenRating.heavy: return 0.8
//				case PollenRating.veryHeavy: return 1.0
//				}
//				}
//				return 0
				return (ss != nil) ? Double(ss!.logValue) : 0.0
			})
			.enumerated()
			.map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })

		let set = LineChartDataSet(values: logValues, label: nil)
//		set.setColor(Style.shared.green)
		set.setColor(UIColor(white: 0.75, alpha: 1.0))
		set.highlightEnabled = true
		set.highlightColor = Style.shared.blue
//		set.highlightAlpha = 1.0
		set.highlightLineWidth = 5.0
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
			set.highlightColor = Style.shared.blue
			set.highlightAlpha = 1.0
			set.highlightLineWidth = 5.0
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
			set.highlightColor = Style.shared.blue
//			set.highlightAlpha = 1.0
			set.highlightLineWidth = 5.0
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
				if let v = value{
					return 0.1 + 0.4 * Double(v)/3
				}
				return 0
			})
			.enumerated().map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
		let set = BarChartDataSet(values: values, label: nil)
		set.highlightColor = Style.shared.blue
		set.highlightAlpha = 1.0
		set.highlightLineWidth = 5.0
		set.drawValuesEnabled = false
		set.setColor(UIColor.white)
		set.colors =
			allergyDataValues.map({
				if $0 == nil{ return UIColor.clear }
				if $0! == 0{ return Style.shared.green }
				if $0! == 1{ return Style.shared.yellow }
				if $0! == 2{ return Style.shared.orange }
				return Style.shared.red
			})
		return BarChartData(dataSet: set)
	}

	func dailyAllergyDataBarChartDataBlack() -> BarChartData{
		let values = allergyDataValues
			.map({ (value) -> Double in
				if let v = value{
					return 0.1 + 0.4 * Double(v)/3
				}
				return 0
			})
			.enumerated().map({ BarChartDataEntry(x: Double($0.offset), y: $0.element) })
		let set = BarChartDataSet(values: values, label: nil)
		set.highlightColor = Style.shared.blue
		set.highlightAlpha = 1.0
		set.highlightLineWidth = 5.0
		set.drawValuesEnabled = false
		set.setColor(UIColor.white)
		set.colors =
			allergyDataValues.map({
				if $0 == nil{ return UIColor.clear }
				return UIColor(white: 0.0, alpha: 0.8)
			})
		return BarChartData(dataSet: set)
	}

	
	func dailyAllergyDataLineChart() -> LineChartData{
		let values = allergyDataValues
			.map({ (value) -> Double in
				if let v = value{
					return 0.1 + 0.4 * Double(v)/3
				}
				return 0
			})
			.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
		
		let rightSplit = values[146 ..< values.count]
		
		let set = LineChartDataSet(values: Array(rightSplit), label: nil)
		set.lineWidth = 3.0
		set.highlightColor = Style.shared.blue
		set.highlightLineWidth = 5.0
		set.drawValuesEnabled = false
		set.drawCirclesEnabled = true
		set.drawCircleHoleEnabled = false
		set.circleRadius = 6.0
		set.setColor(UIColor.white)
		set.cubicIntensity = 0.2
		set.valueColors =
			allergyDataValues.map({
				if $0 == nil{ return UIColor.clear }
				if $0! == 0{ return Style.shared.green }
				if $0! == 1{ return Style.shared.yellow }
				if $0! == 2{ return Style.shared.orange }
				return Style.shared.red
			})
		set.circleColors =
			allergyDataValues.map({
				if $0 == nil{ return UIColor.clear }
				if $0! == 0{ return Style.shared.green }
				if $0! == 1{ return Style.shared.yellow }
				if $0! == 2{ return Style.shared.orange }
				return Style.shared.red
			})
		set.drawFilledEnabled = false
		set.fillAlpha = 1
		set.mode = .cubicBezier
		return LineChartData(dataSet: set)
	}
	
	func dailyAllergyDataFilledLineChart() -> LineChartData {
		let values = allergyDataValues.enumerated().map { (offset, element) -> ChartDataEntry in
			let y = (element == nil) ? 0 : Double(element!)/3
			return ChartDataEntry(x: Double(offset), y: y)
		}
		let set1 = LineChartDataSet(values: values, label: nil)
		set1.lineWidth = 0.1
		set1.highlightColor = Style.shared.blue
		set1.highlightLineWidth = 5.0
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
		let exposureTypes:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})
//		let exposureTypes:[Exposures] = [.dog, .cat, .dust, .molds, .virus]

//		let images:[UIImage] = [#imageLiteral(resourceName: "dog"), #imageLiteral(resourceName: "cat"), #imageLiteral(resourceName: "dust"), #imageLiteral(resourceName: "molds"), #imageLiteral(resourceName: "virus") ]

		let dataSets = array.enumerated().map { (exI, valueArray) -> ChartDataSet in
			let values = valueArray.enumerated().compactMap({ value -> ChartDataEntry? in
				return value.element ? ChartDataEntry(x: Double(value.offset), y: -0.05 - Double(exI)/14) : nil
//				return value.element ? ChartDataEntry(x: Double(value.offset), y: -0.05 - Double(exI)/14, icon: images[exI%5]) : nil
			})
//			let valuesold = valueArray.map{ return $0 ? exI : 0
//				}.enumerated().map({ (j, value) -> ChartDataEntry in
//					return ChartDataEntry(x: Double(j), y: -0.05 - Double(value)/14)
//				})//.filter({ $0.y != 0.0 })

			
//			let values = valueArray.map{ return $0 ? i : 0
//				}.enumerated().map({ (j, value) -> ChartDataEntry in
//					return ChartDataEntry(x: Double(j), y: -0.05 - Double(value)/14)
//				})//.filter({ $0.y != 0.0 })
//			let set = ScatterChartDataSet(values: values + [ChartDataEntry(x: 0, y: 0)], label: exposureTypes[i].asString())
			let set = ScatterChartDataSet(values: values, label: exposureTypes[exI].asString())
//			set.setScatterShape(.circle)
			set.setScatterShape(.square)
			set.highlightLineWidth = 5.0
			set.highlightColor = Style.shared.blue
//			set.highlightAlpha = 1.0
			set.scatterShapeHoleColor = Style.shared.colorFor(exposure: exposureTypes[exI%5])
			set.scatterShapeHoleRadius = 3.5
			set.drawValuesEnabled = false
			set.setColor( Style.shared.colorFor(exposure: exposureTypes[exI%5]) )
			set.scatterShapeSize = 8
			return set
		}
		let data = ScatterChartData(dataSets: dataSets)
		return data
	}
	
	
	func scatterDataBlack(from array:[[Bool]]) -> ScatterChartData{
		let colors = [
			UIColor(white: 0.2, alpha: 1.0),
			UIColor(white: 0.4, alpha: 1.0),
			UIColor(white: 0.6, alpha: 1.0),
			UIColor(white: 0.75, alpha: 1.0),
			UIColor(white: 0.866, alpha: 1.0)
		]

		let exposureTypes:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})
		let dataSets = array.enumerated().map { (exI, valueArray) -> ChartDataSet in
			let values = valueArray.enumerated().compactMap({ value -> ChartDataEntry? in
				return value.element ? ChartDataEntry(x: Double(value.offset), y: -0.05 - Double(exI)/14) : nil
			})
			let set = ScatterChartDataSet(values: values, label: exposureTypes[exI].asString())
			set.setScatterShape(.square)
			set.scatterShapeHoleColor = colors[exI%5]
			set.scatterShapeHoleRadius = 3.5
			set.drawValuesEnabled = false
			set.setColor( colors[exI%5] )
			set.scatterShapeSize = 8
			return set
		}
		let data = ScatterChartData(dataSets: dataSets)
		return data
	}
	
	func dailyClinicDataByGroupsLineChartCombinedData() -> LineChartData{
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
		
		var groupColors = [Style.shared.red.withAlphaComponent(1.0),
						   Style.shared.orange.withAlphaComponent(1.0),
						   Style.shared.blue.withAlphaComponent(0.75),
						   Style.shared.green]

		
		let sets = logValues.enumerated().map { (item) -> LineChartDataSet in
			let set = LineChartDataSet(values: item.element, label: nil)
//			set.setColors(colors, alpha: 1.0)
//			set.setColor(Style.shared.green)
//			set.setColor(UIColor.init(white: 0.0, alpha: 0.25))
//			set.fillColor = UIColor.init(white: 0.0, alpha: 0.25)
			set.setColor(groupColors[item.offset].withAlphaComponent(1.0))
			set.fillColor = groupColors[item.offset]//.withAlphaComponent(0.5)
			set.highlightEnabled = true
			set.highlightColor = Style.shared.blue
//			set.highlightAlpha = 1.0
			set.highlightLineWidth = 5.0
			set.drawValuesEnabled = false
			set.drawFilledEnabled = true
			set.drawCirclesEnabled = false
			set.drawCircleHoleEnabled = false
//			set.circleRadius = 6.0
//			set.setColor(UIColor.white)
			set.cubicIntensity = 0.2
			set.mode = .cubicBezier
//			chartData.barWidth = 1.01
			
			return set
		}
		return LineChartData(dataSets: sets.reversed())
	}

	
}

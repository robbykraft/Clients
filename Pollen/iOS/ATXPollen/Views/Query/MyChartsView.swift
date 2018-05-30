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
	
	let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
	var groupCharts = [LineChartView(), LineChartView(), LineChartView(), LineChartView()]

//	var sliderX: UISlider!
//	var sliderTextX: UITextField!
	
	var lowBounds = Date(fromString: "2017-05-29")!
	var upperBounds = Date(fromString: "2018-05-29")!

	let dateSelector = UISegmentedControl(items: ["Years", "Months", "Weeks"])
	
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
//		self.addSubview(masterChartView)

		
		
		groupCharts.forEach({ self.addSubview($0) })
		
		dateSelector.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
		self.addSubview(dateSelector)

		
		let groups = [PollenTypeGroup.grasses, PollenTypeGroup.weeds, PollenTypeGroup.trees, PollenTypeGroup.molds]
		for i in 0..<labels.count{
			labels[i].font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			labels[i].textColor = Style.shared.blue
			labels[i].text = groups[i].asString()
			labels[i].textAlignment = .left
			labels[i].sizeToFit()
			self.addSubview(labels[i])
		}
		
//		let data = dataWithCount(36, range: 100, color: .white)
//		data.setValueFont(UIFont(name: "HelveticaNeue", size: 7)!)
//		setupChart1(masterChartView, data: data, color: Style.shared.blue)

		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .pollenDidUpdate, object: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		masterChartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height*0.15)
		let h:CGFloat = self.bounds.size.height*0.15
		for i in 0..<groupCharts.count{
			groupCharts[i].frame = CGRect(x: 0, y: h*CGFloat(i), width: self.bounds.size.width, height: h)
		}
		for i in 0..<labels.count{
			labels[i].center = CGPoint(x: 10 + labels[i].frame.size.width*0.5, y: 15 + h*CGFloat(i))
		}
		dateSelector.center = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.9)
	}
	
	@objc func dateChanged(sender:UISegmentedControl){
		upperBounds = Date(fromString: "2018-05-31")!
		switch dateSelector.selectedSegmentIndex{
		case 0: lowBounds = Date(fromString: "2017-05-31")!
		case 1: lowBounds = Date(fromString: "2018-03-31")!
		default: lowBounds = Date(fromString: "2018-05-16")!
		}
		reloadData()
	}

	@objc func reloadData(){
		let samples = ClinicData.shared.pollenSamples.filter({
			if let date = $0.date{ return date.isBetween(lowBounds, and: upperBounds) }
			return false
		})
		
//		print(samples)
//		let largestValues = samples
//			.map({ $0.relevantToMyAllergies() })
//			.map({ (samples:PollenSamples) -> Double in
//			return samples.getSamples().map({Double($0.logValue)}).sorted(by: {$0 > $1}).first ?? 0
//		})
		
//		let largestValues = samples
//			.map({ $0.relevantToMyAllergies() })
//			.compactMap({ $0.strongestSample() })
//			.map({ Double($0.logValue) })

		let bySpecies = [PollenTypeGroup.grasses, PollenTypeGroup.weeds, PollenTypeGroup.trees, PollenTypeGroup.molds]
			.map { (group) -> [PollenSamples] in
				return samples
					.map({ $0.relevantToMyAllergies() })
					.map({ $0.filteredBy(group: group) })
		}
		
		let bySpeciesValues = bySpecies.map({ (samples) -> [Double] in
			return samples.compactMap({ $0.strongestSample() })
				.map({ Double($0.logValue) })
		})
		
		let bySpeciesChartData = bySpeciesValues.map({ return filledChartData(from: $0, color: Style.shared.blue) })
		
//		setupChart1(masterChartView, data: chartData(from: largestValues, color: Style.shared.blue), color: .white)

		for i in 0..<groupCharts.count{
			setupChart1(groupCharts[i], data: bySpeciesChartData[i], color: .white)
		}
	}
	
	func setupChart1(_ chart: LineChartView, data: LineChartData, color: UIColor) {
		(data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = color
		chart.delegate = self
		chart.backgroundColor = color
		chart.chartDescription?.enabled = false
		chart.dragEnabled = true
		chart.setScaleEnabled(true)
		chart.pinchZoomEnabled = false
		chart.setViewPortOffsets(left: 10, top: 0, right: 10, bottom: 0)
		chart.legend.enabled = false
		chart.leftAxis.enabled = false
		chart.leftAxis.spaceTop = 0.4
		chart.leftAxis.spaceBottom = 0.0
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		chart.data = data
		chart.animate(xAxisDuration: 0.5)
	}
	
//	func chartData(from array:[Double], color:UIColor) -> LineChartData {
//		let yVals = array.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
//		let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
//		set1.lineWidth = 1.75
//		set1.circleRadius = 5.0
//		set1.circleHoleRadius = 2.5
//		set1.setColor(color)
//		set1.setCircleColor(color)
//		set1.highlightColor = color
//		set1.drawValuesEnabled = false
//		return LineChartData(dataSet: set1)
//	}
	
	func filledChartData(from array:[Double], color:UIColor) -> LineChartData {
		let yVals = array.enumerated().map({ ChartDataEntry(x: Double($0.offset), y: $0.element) })
		let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
		set1.lineWidth = 0.1
//		set1.circleRadius = 5.0
//		set1.circleHoleRadius = 2.5
//		set1.setColor(color)
//		set1.setCircleColor(color)
		set1.highlightColor = color
		set1.drawValuesEnabled = false
		set1.drawCirclesEnabled = false
		set1.drawFilledEnabled = true
		set1.fillAlpha = 1
		set1.fillColor = color
//		set1.cubicIntensity = 0.5
		set1.mode = .cubicBezier
		return LineChartData(dataSet: set1)
	}

	
//	func dataWithCount(_ count: Int, range: UInt32, color:UIColor) -> LineChartData {
//		let yVals = (0..<count).map { i -> ChartDataEntry in
//			let val = Double(arc4random_uniform(range)) + 3
//			return ChartDataEntry(x: Double(i), y: val)
//		}
//
//		let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
//
//		set1.lineWidth = 1.75
//		set1.circleRadius = 5.0
//		set1.circleHoleRadius = 2.5
//		set1.setColor(color)
//		set1.setCircleColor(color)
//		set1.highlightColor = color
//		set1.drawValuesEnabled = false
//
//		return LineChartData(dataSet: set1)
//	}

}

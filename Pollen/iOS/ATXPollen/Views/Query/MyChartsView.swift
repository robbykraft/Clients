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

	
	var chartView = LineChartView()
	
//	var sliderX: UISlider!
//	var sliderTextX: UITextField!
	
	
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height*0.5)
	}
	
	func initUI(){
		self.addSubview(chartView)

		let data = dataWithCount(36, range: 100)
		data.setValueFont(UIFont(name: "HelveticaNeue", size: 7)!)
		setupChart(chartView, data: data, color: Style.shared.blue)
	}
	
	func setupChart(_ chart: LineChartView, data: LineChartData, color: UIColor) {
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
		chart.leftAxis.spaceBottom = 0.4
		chart.rightAxis.enabled = false
		chart.xAxis.enabled = false
		
		chart.data = data
		
		chart.animate(xAxisDuration: 2.5)
	}
	
	func dataWithCount(_ count: Int, range: UInt32) -> LineChartData {
		let yVals = (0..<count).map { i -> ChartDataEntry in
			let val = Double(arc4random_uniform(range)) + 3
			return ChartDataEntry(x: Double(i), y: val)
		}
		
		let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
		
		set1.lineWidth = 1.75
		set1.circleRadius = 5.0
		set1.circleHoleRadius = 2.5
		set1.setColor(.white)
		set1.setCircleColor(.white)
		set1.highlightColor = .white
		set1.drawValuesEnabled = false
		
		return LineChartData(dataSet: set1)
	}

}

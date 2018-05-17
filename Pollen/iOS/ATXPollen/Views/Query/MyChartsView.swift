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

	
	var masterChartView = LineChartView()
	var chartView1 = LineChartView()
	var chartView2 = LineChartView()

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
		masterChartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height*0.15)
		chartView1.frame = CGRect(x: 0, y: self.bounds.size.height*0.15, width: self.bounds.size.width, height: self.bounds.size.height*0.4)
		chartView2.frame = CGRect(x: 0, y: self.bounds.size.height*0.55, width: self.bounds.size.width, height: self.bounds.size.height*0.4)
	}
	
	func initUI(){
		self.addSubview(masterChartView)
		self.addSubview(chartView1)
		self.addSubview(chartView2)

		let data = dataWithCount(36, range: 100, color: .white)
		data.setValueFont(UIFont(name: "HelveticaNeue", size: 7)!)
		setupChart(masterChartView, data: data, color: Style.shared.blue)
		let data1 = dataWithCount(36, range: 100, color:Style.shared.blue)
		setupChart(chartView1, data: data1, color: .white)
		let data2 = dataWithCount(36, range: 100, color:Style.shared.blue)
		setupChart(chartView2, data: data2, color: .white)
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
	
	func dataWithCount(_ count: Int, range: UInt32, color:UIColor) -> LineChartData {
		let yVals = (0..<count).map { i -> ChartDataEntry in
			let val = Double(arc4random_uniform(range)) + 3
			return ChartDataEntry(x: Double(i), y: val)
		}
		
		let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
		
		set1.lineWidth = 1.75
		set1.circleRadius = 5.0
		set1.circleHoleRadius = 2.5
		set1.setColor(color)
		set1.setCircleColor(color)
		set1.highlightColor = color
		set1.drawValuesEnabled = false
		
		return LineChartData(dataSet: set1)
	}

}

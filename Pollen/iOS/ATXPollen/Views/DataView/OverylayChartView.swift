//
//  OverylayChartView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/12/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import Charts

protocol OverlayChartDelegate{
	func didSelectDate(_ date:Date);
}

extension OverylayChartView: IAxisValueFormatter {
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let intValue = Int(value)
		if intValue < 0 || intValue >= ChartData.shared.clinicDataYearDates.count { return "" }
		let date = ChartData.shared.clinicDataYearDates[intValue]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
//		if      zoomPage == 0 { dateFormatter.dateFormat = "MMM yyyy" }
//		else if zoomPage == 1 { dateFormatter.dateFormat = "MMM d" }
		return dateFormatter.string(from: date)
	}
}

enum OverlayChartMode{
	case combined
	case groups
}

class OverylayChartView: UIView, ChartViewDelegate{
	
	var mode:OverlayChartMode = .combined{
		didSet{
			self.reloadData()
			self.exposureLabel.isHidden = true
			self.pollenGroupsLabel.isHidden = true
			switch mode {
			case .combined: self.exposureLabel.isHidden = false
			case .groups: self.pollenGroupsLabel.isHidden = false
			}
		}
	}

	// charts
	let chartView = CombinedChartView()
	var delegate:OverlayChartDelegate?
	
	let exposureLabel = UILabel()
	let pollenGroupsLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() { self.init(frame: CGRect.zero) }
	required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }
	
	func initUI(){
		let exposureString = "▇ dog  ▇ cat  ▇ dust  ▇ molds  ▇ virus"
		let attributedString = NSMutableAttributedString(string:exposureString)
		let fullRange: NSRange = NSMakeRange(0, exposureString.count)
		attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P15)!, range: fullRange)
		let exposures:[Exposures] = (0..<5).indices.map({Exposures(rawValue: $0)!})
		for exposure in exposures{
			let range = (exposureString as NSString).range(of: "▇ " + exposure.asString())
			attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Style.shared.colorFor(exposure: exposure), range: range)
		}
		exposureLabel.attributedText = attributedString
		exposureLabel.sizeToFit()

	
		var groupColors = [Style.shared.red,
						   Style.shared.orange,
						   Style.shared.blue,
						   Style.shared.green]

//		[.grasses, .weeds, .trees, .molds]
		
//		let groupsString = "▇ trees  ▇ grasses  ▇ molds  ▇ weeds"
		let groupsString = "▇ grasses  ▇ weeds  ▇ trees  ▇ molds"
		let groupsAttributedString = NSMutableAttributedString(string:groupsString)
		let groupsFullRange: NSRange = NSMakeRange(0, groupsString.count)
		groupsAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P15)!, range: groupsFullRange)
//		let groups:[PollenTypeGroup] = [.trees, .grasses, .molds, .weeds]
		let groups:[PollenTypeGroup] = [.grasses, .weeds, .trees, .molds]

		var i = 0
		for group in groups{
			let range = (groupsString as NSString).range(of: "▇ " + group.asString())
			groupsAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: groupColors[i], range: range)
			i += 1
		}
		pollenGroupsLabel.attributedText = groupsAttributedString
		pollenGroupsLabel.sizeToFit()

		
		self.addSubview(exposureLabel)
		self.addSubview(pollenGroupsLabel)
		pollenGroupsLabel.isHidden = true

//		exposureLabels.enumerated().forEach({
//			$0.element.text = Exposures(rawValue: $0.offset)?.asString()
//			$0.element.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
//			$0.element.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
//		})
		
		self.addSubview(chartView)
		chartView.delegate = self

		chartView.chartDescription?.enabled = false
		
		chartView.legend.entries = []
		chartView.legend.form = .none
		chartView.drawBarShadowEnabled = false
		chartView.highlightFullBarEnabled = false
		
		chartView.drawOrder = [DrawOrder.line.rawValue,
							   DrawOrder.bar.rawValue,
							   DrawOrder.scatter.rawValue ]
		
		chartView.xAxis.valueFormatter = self
		chartView.gridBackgroundColor = .clear
		chartView.drawGridBackgroundEnabled = false
		chartView.scaleYEnabled = false
		chartView.getAxis(.left).drawLabelsEnabled = false
		chartView.getAxis(.right).drawLabelsEnabled = false
		chartView.xAxis.granularity = 1
		chartView.getAxis(.left).gridColor = .clear
		chartView.getAxis(.right).gridColor = .clear
		chartView.scaleXEnabled = true
		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.drawAxisLineEnabled = false
		chartView.chartDescription?.enabled = false
		//
		chartView.doubleTapToZoomEnabled = false
		chartView.xAxis.axisMinimum = 0
		chartView.legend.enabled = false
	}
	
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		let index = Int(entry.x)
		if index < 0 || index >= ChartData.shared.clinicDataYearDates.count{ return }
		let date = ChartData.shared.clinicDataYearDates[index]
		delegate?.didSelectDate(date);
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		chartView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height*0.9)
		exposureLabel.sizeToFit()
		exposureLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - exposureLabel.frame.size.height)
		pollenGroupsLabel.sizeToFit()
		pollenGroupsLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - exposureLabel.frame.size.height)
	}

	func reloadData(){
	
		if ChartData.shared.clinicDataYearDates.count == 0{ return }
		
		let data = CombinedChartData()
		switch mode {
		case .combined:
			data.lineData = ChartData.shared.dailyClinicDataLineChartData()
			data.barData = ChartData.shared.dailyAllergyDataBarChartData()
			data.scatterData = ChartData.shared.scatterData(from: ChartData.shared.exposureDataByTypes)
		case .groups:
			data.lineData = ChartData.shared.dailyClinicDataByGroupsLineChartCombinedData()
			data.barData = ChartData.shared.dailyAllergyDataBarChartDataBlack()
			data.scatterData = ChartData.shared.scatterDataBlack(from: ChartData.shared.exposureDataByTypes)
		}
		
		chartView.data = data

		chartView.xAxis.axisMaximum = data.xMax + 0.25
	}
	
}

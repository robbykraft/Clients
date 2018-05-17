//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol QueryViewDelegate{
	func queryViewDateDidChange(date:Date)
}

class QueryView: UIView{
	
	var delegate:QueryViewDelegate?
	
	let segmentedControl = QuerySegmentedControl(items: ["my allergies","my charts"])
	let segmentedHR = UIView()

	// allergies and exposures
	let allergyView = AllergyQueryView()
	let dividerView = UIImageView()
	let exposureView = ExposureQueryView()

	// my charts
	let myChartsView = MyChartsView()
	
	
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
		segmentedHR.backgroundColor = Style.shared.blue
		dividerView.image = UIImage(named: "separator")
		myChartsView.isHidden = true
		self.addSubview(segmentedControl)
		self.addSubview(segmentedHR)
		self.addSubview(allergyView)
		self.addSubview(dividerView)
		self.addSubview(exposureView)
		self.addSubview(myChartsView)
		segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let dividerH:CGFloat = 40
		// segmented control, above user content
		segmentedControl.center = CGPoint(x: self.bounds.size.width * 0.5, y: 20)
		segmentedHR.frame = CGRect(x: 0, y: segmentedControl.frame.origin.y + segmentedControl.frame.size.height-1, width: self.bounds.size.width, height: 1)
		
		// allergies and exposures
		let content = CGRect(x: 0, y: segmentedHR.frame.bottom, width: self.bounds.size.width, height: self.bounds.size.height-segmentedHR.frame.bottom)
		allergyView.frame = CGRect(x: 0, y: content.origin.y, width: content.size.width, height: content.size.height*0.5 - dividerH*0.5)
		dividerView.frame = CGRect(x: -30, y: content.origin.y + content.size.height*0.5 - dividerH*0.5, width: content.size.width+60, height: dividerH)
		exposureView.frame = CGRect(x: 0, y: content.origin.y + content.size.height*0.5 + dividerH*0.5, width: content.size.width, height: content.size.height*0.5 - dividerH*0.5)
		
		// my charts
		myChartsView.frame = content
	}
	
	@objc func segmentedControlDidChange(sender:UISegmentedControl){
		let state:Bool = sender.selectedSegmentIndex == 0 ? false : true
		allergyView.isHidden = state
		dividerView.isHidden = state
		exposureView.isHidden = state
		myChartsView.isHidden = !state
	}
	
}

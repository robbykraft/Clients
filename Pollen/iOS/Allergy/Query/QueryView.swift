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
	
	let segmentedControl = SegmentedControl(items: ["My Allergies","My Charts"])
	let segmentedHR = UIView()

	let allergyView = AllergyQueryView()
	let exposureView = ExposureQueryView()
	
	
	let dividerView = UIView()
	
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
		self.addSubview(segmentedControl)
		self.addSubview(segmentedHR)
		self.addSubview(allergyView)
		self.addSubview(dividerView)
		self.addSubview(exposureView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let dividerH:CGFloat = 40
		// segmented control, above user content
		segmentedControl.center = CGPoint(x: self.bounds.size.width * 0.5, y: 20)
		segmentedHR.frame = CGRect(x: 0, y: segmentedControl.frame.origin.y + segmentedControl.frame.size.height-1, width: self.bounds.size.width, height: 1)
		// user content, below top segmented-control menu
		let content = CGRect(x: 0, y: segmentedHR.frame.bottom, width: self.bounds.size.width, height: self.bounds.size.height-segmentedHR.frame.bottom)
		allergyView.frame = CGRect(x: 0, y: content.origin.y, width: content.size.width, height: content.size.height*0.5 - dividerH*0.5)
		dividerView.frame = CGRect(x: 0, y: content.origin.y + content.size.height*0.5 - dividerH*0.5, width: content.size.width, height: dividerH)
		exposureView.frame = CGRect(x: 0, y: content.origin.y + content.size.height*0.5 + dividerH*0.5, width: content.size.width, height: content.size.height*0.5 - dividerH*0.5)
	}

}

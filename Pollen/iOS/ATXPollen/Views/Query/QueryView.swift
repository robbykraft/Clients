//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class QueryView: UIView{
	let questionButton = UIBorderedButton()
	
	let symptomsCoverView = UIImageView()
	
	let trackYourAllergiesButton = UIButton()
		
//	let segmentedControl = QuerySegmentedControl(items: ["my allergies","my charts"])
//	let segmentedHR = UIView()

	// allergies and exposures
//	let allergyView = AllergyQueryView()
//	let dividerView = UIImageView()
//	let exposureView = ExposureQueryView()

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
//		segmentedHR.backgroundColor = Style.shared.blue
//		dividerView.image = UIImage(named: "separator")

//		segmentedControl.selectedSegmentIndex = 1
//		myChartsView.isHidden = true
//		allergyView.isHidden = true
//		dividerView.isHidden = true
//		exposureView.isHidden = true

//		self.addSubview(segmentedControl)
//		self.addSubview(segmentedHR)
//		self.addSubview(allergyView)
//		self.addSubview(dividerView)
//		self.addSubview(exposureView)
		
		symptomsCoverView.image = UIImage(named: "cutout")

		trackYourAllergiesButton.setTitle("track your allergies", for: .normal)
		trackYourAllergiesButton.setTitleColor(.black, for: .normal)
		trackYourAllergiesButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		trackYourAllergiesButton.sizeToFit()

		self.addSubview(myChartsView)
		self.addSubview(symptomsCoverView)
		self.addSubview(trackYourAllergiesButton)
		self.addSubview(questionButton)
//		segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		let dividerH:CGFloat = 40
//		// segmented control, above user content
//		segmentedControl.center = CGPoint(x: self.bounds.size.width * 0.5, y: 20)
//		segmentedHR.frame = CGRect(x: 0, y: segmentedControl.frame.origin.y + segmentedControl.frame.size.height-1, width: self.bounds.size.width, height: 1)
//
//		// allergies and exposures
//		let content = CGRect(x: 0, y: segmentedHR.frame.bottom, width: self.bounds.size.width, height: self.bounds.size.height-segmentedHR.frame.bottom)
//
//		let pctTop:CGFloat = 0.45
//		allergyView.frame = CGRect(x: 0, y: content.origin.y, width: content.size.width, height: content.size.height*pctTop - dividerH*0.5)
//		dividerView.frame = CGRect(x: -30, y: content.origin.y + content.size.height*pctTop - dividerH*0.5, width: content.size.width+60, height: dividerH)
//		exposureView.frame = CGRect(x: 0, y: content.origin.y + content.size.height*pctTop + dividerH*0.5, width: content.size.width, height: content.size.height*(1-pctTop) - dividerH*0.5)

		// my charts
		myChartsView.frame = self.bounds
		
		symptomsCoverView.frame = myChartsView.getSymptomChartsFrame()
		if(Symptom.shared.entries.count > 0){ symptomsCoverView.isHidden = true }

		trackYourAllergiesButton.center = CGPoint(x: symptomsCoverView.center.x, y: symptomsCoverView.center.y)

		questionButton.setTitle("Allergies?", for: .normal)
		questionButton.sizeToFit()
		questionButton.frame = CGRect(x: 0, y: 0, width: questionButton.bounds.size.width+40, height: questionButton.bounds.size.height+15)
		questionButton.color = .black
		questionButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.93)
		questionButton.addTarget(self, action: #selector(openQuestion), for: .touchUpInside)
	}
	
	
	@objc func openQuestion(){
		let alert = PopAlertView(title: "(1 / 2)", view: AllergyQueryView())
		alert.show(animated: true)
	}
	
//	@objc func segmentedControlDidChange(sender:UISegmentedControl){
//		let state:Bool = sender.selectedSegmentIndex == 0 ? false : true
//		allergyView.isHidden = state
//		dividerView.isHidden = state
//		exposureView.isHidden = state
//		myChartsView.isHidden = !state
//	}
	
}

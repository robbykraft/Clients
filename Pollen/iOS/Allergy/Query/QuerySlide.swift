//
//  QuerySlide.swift
//  Allergy
//
//  Created by Robby on 10/17/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class QuerySlide: UIView {

	let scrollView = UIScrollView()
	let coverButton = UIButton()
	let coverText = UILabel()
	let detailText = UILabel()
	
	let responseButtons:[UIButton] = [UIButton(), UIButton(), UIButton(), UIButton()]

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
	
	func initUI() {
		coverText.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
		coverText.textColor = Style.shared.blue

		detailText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		detailText.textColor = Style.shared.blue

		
		coverButton.addTarget(self, action: #selector(coverButtonHandler), for: .touchUpInside)

		scrollView.showsHorizontalScrollIndicator = false
		scrollView.isScrollEnabled = false
		self.addSubview(scrollView)
		
		scrollView.addSubview(coverText)
		scrollView.addSubview(coverButton)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		scrollView.contentSize = CGSize(width: self.bounds.size.width*2, height: self.bounds.size.height)
		scrollView.frame = self.bounds
		
		coverText.sizeToFit()

		let pct:CGFloat = 0.9
		coverButton.frame = CGRect(x: 0, y: 0, width: self.bounds.height*pct, height: self.bounds.height*pct)
		coverButton.layer.cornerRadius = self.bounds.height*pct*0.5
		coverButton.layer.borderColor = Style.shared.blue.cgColor
		coverButton.layer.borderWidth = 4
		coverButton.center = CGPoint(x:self.bounds.size.width*0.25, y:self.bounds.size.height*0.5)

		coverText.center = CGPoint(x: coverButton.center.x +
		                              coverButton.frame.size.width*0.5 +
		                              10 + 
		                              coverText.frame.size.width*0.5, y: self.bounds.height*0.5)

		let btnTexts = ["none", "low", "med", "high"];
//		let pad:CGFloat = 20
		let btnH:CGFloat = self.bounds.height*pct
		let startX:CGFloat = self.bounds.size.width + (self.bounds.size.width - btnH*4) * 0.5
		for i in 0..<responseButtons.count{
			responseButtons[i].frame = CGRect(x: 0, y: 0, width: self.bounds.height*pct, height: self.bounds.height*pct)
			responseButtons[i].layer.cornerRadius = self.bounds.height*pct*0.5
			responseButtons[i].layer.borderColor = Style.shared.blue.cgColor
			responseButtons[i].setTitle(btnTexts[i], for: .normal)
			responseButtons[i].titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P21)
			responseButtons[i].setTitleColor(Style.shared.blue, for: .normal)
			responseButtons[i].layer.borderWidth = 4
			responseButtons[i].center = CGPoint(x:btnH*0.5 + startX + btnH*CGFloat(i), y:self.bounds.size.height*0.5)
			
			responseButtons[i].addTarget(self, action: #selector(responseButtonHandler), for: .touchUpInside)
			self.scrollView.addSubview(responseButtons[i])
		}
	}
	
	@objc func responseButtonHandler(){
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), animated: true)
	}
	
	@objc func coverButtonHandler(){
		self.scrollView.scrollRectToVisible(CGRect(x: self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height), animated: true)
	}
}

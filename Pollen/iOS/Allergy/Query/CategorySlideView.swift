//
//  CategorySlideView.swift
//  Allergy
//
//  Created by Robby on 11/15/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol CategorySlideDelegate: class {
	func didSelectCategory(index: Int)
}
class CategorySlideView: UIView {

	var delegate:CategorySlideDelegate?

	let scrollView = UIScrollView()
	let imageNames = ["eye", "sinus", "nose", "throat",
					  "eye", "sinus", "nose", "throat",
					  "eye", "sinus", "nose", "throat",
					  "eye", "sinus", "nose", "throat"]
	var buttons:[UIButton] = Array(repeating: UIButton(), count: SymptomCategories.count)
	var categoryColors:[UIColor] = Array(repeating: Style.shared.blue, count: SymptomCategories.count)
	
	let nextPageButton = UIButton()
	let prevPageButton = UIButton()

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
		
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.isScrollEnabled = false
		scrollView.isPagingEnabled = true
		self.addSubview(scrollView)
		
		nextPageButton.setTitleColor(Style.shared.blue, for: .normal)
		prevPageButton.setTitleColor(Style.shared.blue, for: .normal)
		nextPageButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		prevPageButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		nextPageButton.setTitle("▶︎", for: .normal)
		prevPageButton.setTitle("◀︎", for: .normal)
		nextPageButton.sizeToFit()
		prevPageButton.sizeToFit()
		nextPageButton.addTarget(self, action: #selector(nextPageButtonHandler), for: .touchUpInside)
		prevPageButton.addTarget(self, action: #selector(prevPageButtonHandler), for: .touchUpInside)
		self.addSubview(nextPageButton)
		self.addSubview(prevPageButton)
		
		for i in 0 ..< self.categoryColors.count {
			self.categoryColors[i] = Style.shared.blue
		}

		for i in 0 ..< self.buttons.count {
			self.buttons[i] = UIButton()
			if i < imageNames.count{
				let buttonImage = UIImage(named:imageNames[i])?.maskWithColor(color: Style.shared.blue)
				self.buttons[i].setImage(buttonImage, for: .normal)
			}
			self.buttons[i].titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P21)
			self.buttons[i].layer.borderWidth = 4
			self.buttons[i].layer.masksToBounds = true
			self.buttons[i].tag = i
			self.buttons[i].addTarget(self, action: #selector(responseButtonHandler(sender:)), for: .touchUpInside)
			self.scrollView.addSubview(self.buttons[i])
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		scrollView.contentSize = CGSize(width: self.bounds.size.width*4, height: self.bounds.size.height)
		scrollView.frame = self.bounds
		
		let pct:CGFloat = 1.0/6
		let btnH:CGFloat = self.bounds.width*pct
		
		prevPageButton.center = CGPoint(x: btnH * 0.5, y: self.bounds.size.height*0.5)
		nextPageButton.center = CGPoint(x: self.bounds.size.width - btnH * 0.5, y: self.bounds.size.height*0.5)

		for i in 0 ..< self.buttons.count {
			let buttonColor = categoryColors[i]
			let page = CGFloat(Int(Double(i) / 4.0))
			let iMod4 = CGFloat(i%4)
			let startX:CGFloat = page*self.bounds.size.width + (self.bounds.size.width - btnH*4) * 0.5
			self.buttons[i].frame = CGRect(x: 0, y: 0, width: btnH, height: btnH)
			self.buttons[i].layer.cornerRadius = btnH*0.5
			if i < imageNames.count{
				let buttonImage = UIImage(named:imageNames[i])?.maskWithColor(color: buttonColor)
				self.buttons[i].setImage(buttonImage, for: .normal)
			}
			self.buttons[i].layer.borderColor = buttonColor.cgColor
			self.buttons[i].center = CGPoint(x:btnH*0.5 + startX + btnH*iMod4, y:self.bounds.size.height*0.5)
		}
	}
	
	@objc func responseButtonHandler(sender:UIButton){
		if let delegate = self.delegate{
			delegate.didSelectCategory(index: sender.tag)
		}
	}
	
	@objc func nextPageButtonHandler(){
		let currentOffset = self.scrollView.contentOffset
		self.scrollView.scrollRectToVisible(CGRect(x:currentOffset.x + self.bounds.size.width, y:currentOffset.y, width:self.bounds.size.width, height:self.bounds.size.height), animated: true)
	}
	
	@objc func prevPageButtonHandler(){
		let currentOffset = self.scrollView.contentOffset
		self.scrollView.scrollRectToVisible(CGRect(x:currentOffset.x - self.bounds.size.width, y:currentOffset.y, width:self.bounds.size.width, height:self.bounds.size.height), animated: true)
	}
	
//	@objc func coverButtonHandler(){
//		self.scrollView.scrollRectToVisible(CGRect(x: self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height), animated: true)
//	}
	
	@objc func coverButtonSetSelected(){
//		coverButton.layer.backgroundColor = Style.shared.blue.cgColor
	}
	@objc func coverButtonSetUnselected(){
//		coverButton.layer.backgroundColor = UIColor.white.cgColor
	}
}
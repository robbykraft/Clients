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
	
	var selected:Int?{
		didSet{
			self.setNeedsLayout()
		}
	}

	let scrollView = UIScrollView()
	
	var buttons:[UIButton] = Array(repeating: UIButton(), count: SymptomCategories.count)
	var categoryColors:[UIColor] = Array(repeating: UIColor.black, count: SymptomCategories.count)
	
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
		
		nextPageButton.setTitleColor(UIColor(white: 0.0, alpha: 1.0), for: .normal)
		prevPageButton.setTitleColor(UIColor(white: 0.0, alpha: 1.0), for: .normal)
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
			self.categoryColors[i] = UIColor.gray
		}

		for i in 0 ..< self.buttons.count {
			self.buttons[i] = UIButton()
			guard let imageName = SymptomImageNames[ SymptomCategories[i] ] else {return}
			let buttonImage = UIImage(named:imageName)?.maskWithColor(color: categoryColors[i])
			self.buttons[i].setImage(buttonImage, for: .normal)
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

//		let startX:CGFloat = (self.bounds.size.width-btnH*4)*0.5
		let xPos:[CGFloat] = [
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + 0,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*1,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*2,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*3,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*0.5,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*1.5,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 0*self.bounds.size.width + btnH*2.5,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 1*self.bounds.size.width + btnH*0,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 1*self.bounds.size.width + btnH*1,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 1*self.bounds.size.width + btnH*2,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 1*self.bounds.size.width + btnH*3,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 2*self.bounds.size.width + btnH*0,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 2*self.bounds.size.width + btnH*1,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 2*self.bounds.size.width + btnH*2,
			btnH*0.5 + (self.bounds.size.width-btnH*4)*0.5 + 2*self.bounds.size.width + btnH*3,
		]
		
		let yPos:[CGFloat] = [
			self.bounds.size.height*0.33,
			self.bounds.size.height*0.33,
			self.bounds.size.height*0.33,
			self.bounds.size.height*0.33,
			self.bounds.size.height*0.66,
			self.bounds.size.height*0.66,
			self.bounds.size.height*0.66,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5
		]
		
		for i in 0 ..< self.buttons.count {
			let buttonColor = categoryColors[i]
			self.buttons[i].frame = CGRect(x: 0, y: 0, width: btnH, height: btnH)
			self.buttons[i].layer.cornerRadius = btnH*0.5
			guard let imageName = SymptomImageNames[ SymptomCategories[i] ] else {return}
			let buttonImage = UIImage(named:imageName)?.maskWithColor(color: categoryColors[i])
			self.buttons[i].setImage(buttonImage, for: .normal)
			self.buttons[i].layer.borderColor = buttonColor.cgColor
			self.buttons[i].center = CGPoint(x:xPos[i], y:yPos[i])
			// reset all selected colors
			self.buttons[i].layer.shadowRadius = 0
			self.buttons[i].layer.shadowOpacity = 0.0
		}
		if let index = selected{
			self.buttons[index].layer.shadowRadius = Style.shared.P15*0.5
			self.buttons[index].layer.shadowOpacity = 0.33
			self.buttons[index].layer.shadowColor = categoryColors[index].cgColor
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

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
class CategorySlideView: UIView, UIScrollViewDelegate {

	var delegate:CategorySlideDelegate?
	
	var selectionCircle = UIView()
	
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
		scrollView.delegate = self
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

		// set initial scroll to the far left
		prevPageButton.alpha = 0.0

		self.scrollView.addSubview(selectionCircle)
		
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
		
		scrollView.contentSize = CGSize(width: self.bounds.size.width*3, height: self.bounds.size.height)
		scrollView.frame = self.bounds
		
		let pct:CGFloat = 1.0/6
		let btnH:CGFloat = self.bounds.width*pct
		
		prevPageButton.center = CGPoint(x: btnH * 0.5, y: self.bounds.size.height*0.5)
		nextPageButton.center = CGPoint(x: self.bounds.size.width - btnH * 0.5, y: self.bounds.size.height*0.5)

		let xPad:CGFloat = self.bounds.width*0.01
		let a:CGFloat = btnH*0.5 + (self.bounds.size.width-btnH*4-xPad*4)*0.5
		let b:CGFloat = self.bounds.size.width

//		let startX:CGFloat = (self.bounds.size.width-btnH*4)*0.5
		let xPos:[CGFloat] = [
			a + 0 * b + 0 + xPad*0,
			a + 0 * b + btnH*1 + xPad*1,
			a + 0 * b + btnH*2 + xPad*2,
			a + 0 * b + btnH*3 + xPad*3,
			a + 0 * b + btnH*0.5 + xPad*0.5,
			a + 0 * b + btnH*1.5 + xPad*1.5,
			a + 0 * b + btnH*2.5 + xPad*2.5,
			a + 1 * b + btnH*0 + xPad*0,
			a + 1 * b + btnH*1 + xPad*1,
			a + 1 * b + btnH*2 + xPad*2,
			a + 1 * b + btnH*3 + xPad*3,
			a + 2 * b + btnH*0 + xPad*0,
			a + 2 * b + btnH*1 + xPad*1,
			a + 2 * b + btnH*2 + xPad*2,
			a + 2 * b + btnH*3 + xPad*3,
			]

		let yPos:[CGFloat] = [
			self.bounds.size.height*0.275,
			self.bounds.size.height*0.275,
			self.bounds.size.height*0.275,
			self.bounds.size.height*0.275,
			self.bounds.size.height*0.725,
			self.bounds.size.height*0.725,
			self.bounds.size.height*0.725,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5,
			self.bounds.size.height*0.5
		]
		
		selectionCircle.frame = CGRect(x: 0, y: 0, width: btnH*1.05, height: btnH*1.05)
		selectionCircle.layer.cornerRadius = btnH*1.05*0.5
		selectionCircle.layer.shadowRadius = btnH * 0.033
		selectionCircle.layer.shadowOpacity = 1.0
		selectionCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
		if let index = selected{
			selectionCircle.backgroundColor = categoryColors[index]
			selectionCircle.layer.shadowColor = categoryColors[index].cgColor
		} else{
			selectionCircle.backgroundColor = UIColor.clear
			selectionCircle.layer.shadowColor = UIColor.clear.cgColor
		}
		
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
			self.buttons[i].backgroundColor = UIColor.white
		}
		if let index = selected{
			self.scrollView.bringSubview(toFront: selectionCircle)
			self.scrollView.bringSubview(toFront: self.buttons[index])
			selectionCircle.center = self.buttons[index].center
		}
	}
	
	@objc func responseButtonHandler(sender:UIButton){
		if let delegate = self.delegate{
			delegate.didSelectCategory(index: sender.tag)
		}
	}
	
	@objc func nextPageButtonHandler(){
		let currentOffset = self.scrollView.contentOffset
		
		let page = Int(currentOffset.x / self.bounds.size.width)
		if let delegate = self.delegate{
			switch page{
			case 0: delegate.didSelectCategory(index: 7)
			case 1: delegate.didSelectCategory(index: 11)
			default: delegate.didSelectCategory(index: 11)
			}
		}

		self.scrollView.scrollRectToVisible(CGRect(x:currentOffset.x + self.bounds.size.width, y:currentOffset.y, width:self.bounds.size.width, height:self.bounds.size.height), animated: true)
	}
	
	@objc func prevPageButtonHandler(){
		let currentOffset = self.scrollView.contentOffset

		let page = Int(currentOffset.x / self.bounds.size.width)
		if let delegate = self.delegate{
			switch page{
			case 1: delegate.didSelectCategory(index: 0)
			case 2: delegate.didSelectCategory(index: 7)
			default: delegate.didSelectCategory(index: 0)
			}
		}

		self.scrollView.scrollRectToVisible(CGRect(x:currentOffset.x - self.bounds.size.width, y:currentOffset.y, width:self.bounds.size.width, height:self.bounds.size.height), animated: true)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.x <= 0{
			prevPageButton.alpha = 0.0
		} else{
			prevPageButton.alpha = 1.0
		}
		if scrollView.contentOffset.x >= self.bounds.size.width*2{
			nextPageButton.alpha = 0.0
		} else{
			nextPageButton.alpha = 1.0
		}
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

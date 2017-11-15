//
//  CategorySlideView.swift
//  Allergy
//
//  Created by Robby on 11/15/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol CategorySlideDelegate: class {
	func didSelectButton(index: Int)
}
class CategorySlideView: UIView {

	var delegate:CategorySlideDelegate?

	let scrollView = UIScrollView()
	let buttons:[UIButton] = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
	
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
		
//		coverButton.addTarget(self, action: #selector(coverButtonHandler), for: .touchUpInside)
//		coverButton.addTarget(self, action: #selector(coverButtonSetSelected), for: .touchDown)
//		coverButton.addTarget(self, action: #selector(coverButtonSetSelected), for: .touchDragEnter)
//
//		coverButton.addTarget(self, action: #selector(coverButtonSetUnselected), for: .touchDragOutside)
//		coverButton.addTarget(self, action: #selector(coverButtonSetUnselected), for: .touchCancel)
//		coverButton.addTarget(self, action: #selector(coverButtonSetUnselected), for: .touchDragExit)
//		coverButton.addTarget(self, action: #selector(coverButtonSetUnselected), for: .touchUpInside)
		
//		coverButton.setBackgroundImage(UIImage(named:"white")?.imageWithTint(Style.shared.blue), for: .selected)
//		coverButton.setBackgroundImage(UIImage(named:"white")?.imageWithTint(Style.shared.blue), for: .highlighted)
		
		scrollView.showsHorizontalScrollIndicator = false
//		scrollView.isScrollEnabled = false
		scrollView.isPagingEnabled = true
		self.addSubview(scrollView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		scrollView.contentSize = CGSize(width: self.bounds.size.width*2, height: self.bounds.size.height)
		scrollView.frame = self.bounds
		
		let pct:CGFloat = 0.9
//		coverButton.frame = CGRect(x: 0, y: 0, width: self.bounds.height*pct, height: self.bounds.height*pct)
//		coverButton.layer.cornerRadius = self.bounds.height*pct*0.5
//		coverButton.layer.backgroundColor = UIColor.white.cgColor
//		coverButton.layer.borderColor = Style.shared.blue.cgColor
//		coverButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P21)
//		coverButton.setTitleColor(Style.shared.blue, for: .normal)
//		coverButton.layer.borderWidth = 4
//		coverButton.center = CGPoint(x:self.bounds.size.width*0.25, y:self.bounds.size.height*0.5)
		
//		let btnTexts = ["none", "low", "med", "high"];
//		let pad:CGFloat = 20
		let btnH:CGFloat = self.bounds.height*pct
//		let startX:CGFloat = self.bounds.size.width + (self.bounds.size.width - btnH*4) * 0.5
		
		let images = ["eye", "nose", "sinus", "throat"]
		for i in 0 ..< self.buttons.count {
			let page = CGFloat(Int(Double(i) / 4.0))
			let iMod4 = CGFloat(i%4)
			let startX:CGFloat = page*self.bounds.size.width + (self.bounds.size.width - btnH*4) * 0.5
			self.buttons[i].frame = CGRect(x: 0, y: 0, width: self.bounds.height*pct, height: self.bounds.height*pct)
			self.buttons[i].layer.cornerRadius = self.bounds.height*pct*0.5
			self.buttons[i].layer.borderColor = Style.shared.blue.cgColor
			if i < images.count{
				let buttonImage = UIImage(named:images[i])?.maskWithColor(color: Style.shared.blue)
				self.buttons[i].setImage(buttonImage, for: .normal)
			}
//			self.buttons[i].setTitle(btnTexts[i], for: .normal)
			self.buttons[i].titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P21)
			self.buttons[i].setTitleColor(Style.shared.blue, for: .normal)
			self.buttons[i].layer.borderWidth = 4
			self.buttons[i].layer.masksToBounds = true
			self.buttons[i].tag = i
			self.buttons[i].center = CGPoint(x:btnH*0.5 + startX + btnH*iMod4, y:self.bounds.size.height*0.5)
			self.buttons[i].addTarget(self, action: #selector(responseButtonHandler(sender:)), for: .touchUpInside)
			self.scrollView.addSubview(self.buttons[i])
		}
	}
	
	@objc func responseButtonHandler(sender:UIButton){
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), animated: true)
		if let delegate = self.delegate{
			delegate.didSelectButton(index: sender.tag)
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

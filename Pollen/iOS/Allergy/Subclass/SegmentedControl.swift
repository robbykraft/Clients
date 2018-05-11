//
//  SegmentedControl.swift
//  Allergy
//
//  Created by Robby Kraft on 5/11/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {
	
	let selectedBackgroundColor = UIColor(red: 19/255, green: 59/255, blue: 85/255, alpha: 0.5)
	var sortedViews: [UIView]!
	var currentIndex: Int = 0
	
	override init(items: [Any]?) {
		super.init(items: items)
		configure()
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	private func configure() {
		sortedViews = self.subviews.sorted(by:{$0.frame.origin.x < $1.frame.origin.x})
		changeSelectedIndex(to: currentIndex)
		self.tintColor = UIColor.white
		self.layer.cornerRadius = 4
		self.clipsToBounds = true
		let unselectedAttributes = [NSForegroundColorAttributeName: UIColor.white,
									NSFontAttributeName:  UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)]
		self.setTitleTextAttributes(unselectedAttributes, for: .normal)
		self.setTitleTextAttributes(unselectedAttributes, for: .selected)
	}
	
	func changeSelectedIndex(to newIndex: Int) {
		if currentIndex >= sortedViews.count { return; }
		sortedViews[currentIndex].backgroundColor = UIColor.clear
		currentIndex = newIndex
		self.selectedSegmentIndex = UISegmentedControlNoSegment
		sortedViews[currentIndex].backgroundColor = selectedBackgroundColor
	}
}

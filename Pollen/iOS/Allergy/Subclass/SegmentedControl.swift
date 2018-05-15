//
//  SegmentedControl.swift
//  Allergy
//
//  Created by Robby Kraft on 5/11/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {
	
	let selectedBackgroundColor = Style.shared.blue
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
		self.tintColor = Style.shared.blue
		self.layer.cornerRadius = 4
		self.clipsToBounds = true
		let font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24) ?? UIFont.boldSystemFont(ofSize: Style.shared.P18)
		let unselectedAttributes:[AnyHashable:Any] = [NSForegroundColorAttributeName: Style.shared.blue,
													  NSFontAttributeName: font]
		let selectedAttributes:[AnyHashable:Any] = [NSForegroundColorAttributeName: UIColor.white,
													NSFontAttributeName: font]
		self.setTitleTextAttributes(unselectedAttributes, for: .normal)
		self.setTitleTextAttributes(selectedAttributes, for: .selected)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
//		self.subviews.forEach({ (view) in
////			view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 140, height: 80)
//			view.subviews.filter { (view) -> Bool in
//				print(type(of: view))
//				print(UILabel.self)
//				return type(of: view) == UILabel.self
//			}
//		})

	}
	
	func changeSelectedIndex(to newIndex: Int) {
//		if currentIndex >= sortedViews.count { return; }
//		sortedViews[currentIndex].backgroundColor = UIColor.clear
		currentIndex = newIndex
//		self.selectedSegmentIndex = UISegmentedControlNoSegment
//		sortedViews[currentIndex].backgroundColor = selectedBackgroundColor
	}
}

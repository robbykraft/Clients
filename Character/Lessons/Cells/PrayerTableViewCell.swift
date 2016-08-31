//
//  PrayerTableViewCell.swift
//  Character
//
//  Created by Robby on 8/30/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class PrayerTableViewCell: SuperLessonTableViewCell {
	
	override func initUI() {
		super.initUI()
		cornerTitleLabel.text = "Daily Prayer"
		self.textLabel?.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P30)
		self.textLabel?.numberOfLines = 1
		self.textLabel?.textColor = Style.shared.darkGray
		self.textLabel?.text = "Dear God,..."
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		self.initUI()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad = self.textBoxView.frame.size.width*0.1
		let topBottomPad:CGFloat = 30
		self.textLabel?.frame = CGRectMake(self.textBoxView.frame.origin.x + pad, topBottomPad,
		                                   self.textBoxView.frame.size.width - pad*2, self.frame.size.height - topBottomPad*2)
		self.textLabel?.sizeToFit()
//		self.textLabel?.frame = CGRectMake(self.textBoxView.frame.origin.x + pad, topBottomPad,
//		                                   self.textBoxView.frame.size.width - pad*2, (self.textLabel?.frame.size.height)!)
		self.textLabel?.center = textBoxView.center
	}
	
	override func styleSelected(selected: Bool) {
		super.styleSelected(selected)
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}
	
}

//
//  PrayerTableViewCell.swift
//  Character
//
//  Created by Robby on 8/30/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class PledgeTableViewCell: SuperLessonTableViewCell {
	
	override func initUI() {
		super.initUI()
//		cornerTitleLabel.text = "Daily Prayer"
//		cornerTitleLabel.text = "Daily Pledge"
		cornerTitleLabel.text = "Daily " + Character.shared.pledgeTypeName.capitalized
		self.textLabel?.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P30)
		self.textLabel?.numberOfLines = 1
		self.textLabel?.textColor = Style.shared.darkGray
//		self.textLabel?.text = "Dear God,..."
//		self.textLabel?.text = "I am grateful..."
		self.textLabel?.text = Character.shared.pledgeBodyShort

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
		self.textLabel?.frame = CGRect(x: self.textBoxView.frame.origin.x + pad, y: topBottomPad,
		                                   width: self.textBoxView.frame.size.width - pad*2, height: self.frame.size.height - topBottomPad*2)
		self.textLabel?.sizeToFit()
//		self.textLabel?.frame = CGRectMake(self.textBoxView.frame.origin.x + pad, topBottomPad,
//		                                   self.textBoxView.frame.size.width - pad*2, (self.textLabel?.frame.size.height)!)
		self.textLabel?.center = textBoxView.center
	}
	
	override func styleSelected(_ selected: Bool) {
		super.styleSelected(selected)
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}
	
}

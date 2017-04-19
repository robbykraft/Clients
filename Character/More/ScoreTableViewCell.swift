//
//  ScoreTableViewCell.swift
//  Character
//
//  Created by Robby on 4/18/17.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

class ScoreTableViewCell: DateTableViewCell {
	
	let scores = [UILabel(), UILabel(), UILabel(), UILabel()]
	
	override func initUI() {
		super.initUI()
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		self.textLabel?.textColor = Style.shared.darkGray
		self.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		for label in scores {
			label.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
			label.textColor = Style.shared.green
			label.textAlignment = .center
			label.backgroundColor = UIColor.clear
			self.addSubview(label)
		}
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
		for i in 0..<scores.count {
			scores[i].frame = CGRect.init(x: 0, y: 0, width: 80, height: 50)
			scores[i].center = CGPoint.init(x: self.frame.size.width/4.0*CGFloat(i) + self.frame.size.width/8.0, y: self.frame.size.height * 0.5)
		}
	}
	
}

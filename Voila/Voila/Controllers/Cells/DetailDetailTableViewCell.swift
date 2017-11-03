//
//  DetailDetailTableViewCell.swift
//  Voila
//
//  Created by Robby on 10/31/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class DetailDetailTableViewCell: UITableViewCell {

	let detailDetailTextLabel = UILabel()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		self.initUI()
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.initUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}
	
	func initUI(){
		self.addSubview(self.detailDetailTextLabel)
		
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		self.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		self.detailDetailTextLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.backgroundColor = .white

		// selection color
		let bgColorView = UIView()
		bgColorView.backgroundColor = Style.shared.cellSelectionColor
		self.selectedBackgroundView = bgColorView
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.textLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: self.frame.size.height * 0.66)
		self.detailDetailTextLabel.frame = CGRect(x: 10, y: self.frame.size.height * 0.66 - 3, width: self.frame.size.width, height: self.frame.size.height * 0.33)
	}
	
}

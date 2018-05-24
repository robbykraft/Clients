//
//  CenteredTableViewCell.swift
//  Allergy
//
//  Created by Robby on 5/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class CenteredTableViewCell: UITableViewCell {

	override func layoutSubviews() {
		super.layoutSubviews()
		self.detailTextLabel?.sizeToFit()
		self.textLabel?.sizeToFit()
		let centerPoint = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5)
		self.textLabel?.center = centerPoint
		self.detailTextLabel?.center = centerPoint
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initUI()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		initUI()
	}
	func initUI(){
		self.textLabel?.textAlignment = .center
		self.detailTextLabel?.textAlignment = .center
	}

}

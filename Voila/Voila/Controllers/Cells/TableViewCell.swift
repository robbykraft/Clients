//
//  TableViewCell.swift
//  Voila
//
//  Created by Robby on 10/31/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {


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
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		self.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		self.backgroundColor = .white
		
		// selection color
		let bgColorView = UIView()
		bgColorView.backgroundColor = Style.shared.cellSelectionColor
		self.selectedBackgroundView = bgColorView
	}
	
}

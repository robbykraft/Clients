//
//  PillarSwitchTableViewCell.swift
//  Character
//
//  Created by Robby on 4/4/17.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

protocol PillarSwitchDelegate: class {
	func didPressSwitch(sender: UISwitch)
}

class PillarSwitchTableViewCell: UITableViewCell {
	
	weak var delegate:PillarSwitchDelegate?
	var sw = UISwitch()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initUI()
	}
	
	func initUI(){
		sw.addTarget(self, action: #selector(didSwitch), for: .touchUpInside)
		self.addSubview(sw)
	}
	
	func didSwitch(_:UISwitch){
		delegate?.didPressSwitch(sender: sw)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		sw.center = CGPoint(x: self.bounds.size.width - 100, y: self.bounds.size.height*0.5)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}
	
}

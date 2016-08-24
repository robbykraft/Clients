//
//  SuperLessonTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class SuperLessonTableViewCell: UITableViewCell {

	let textBoxView = UIView()
	let cornerTitleLabel = UILabel()
	
	func initUI() {
		self.backgroundColor = UIColor.clearColor()
	
		textBoxView.layer.borderColor = Style.shared.lightBlue.CGColor
		textBoxView.layer.borderWidth = 1
		textBoxView.backgroundColor = UIColor.whiteColor()
		
		cornerTitleLabel.backgroundColor = Style.shared.darkGray
		cornerTitleLabel.textColor = UIColor.whiteColor()
		cornerTitleLabel.font = UIFont(name: SYSTEM_FONT_I, size: 17)
		cornerTitleLabel.textAlignment = .Center

		self.addSubview(textBoxView)
		self.sendSubviewToBack(textBoxView)
		self.addSubview(cornerTitleLabel)
	}
	
	override func layoutSubviews() {
		let pad:CGFloat = 15
		textBoxView.frame = CGRectMake(pad, pad,
		                               self.frame.size.width-pad*2, self.frame.size.height-pad*2)
		cornerTitleLabel.sizeToFit()
		let cornerW = cornerTitleLabel.frame.size.width*1.2
		cornerTitleLabel.frame = CGRectMake(textBoxView.frame.origin.x+textBoxView.frame.size.width - cornerW, pad,
		                                    cornerW, cornerTitleLabel.frame.size.height)
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
        // Initialization code
		self.initUI()
    }
	
	func styleSelected(selected: Bool){
		if(selected){
			cornerTitleLabel.backgroundColor = Style.shared.lightBlue
			self.textLabel?.textColor = Style.shared.lightBlue
		}
		else{
			cornerTitleLabel.backgroundColor = Style.shared.darkGray
			self.textLabel?.textColor = UIColor.blackColor()
		}
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		// don't call super
		styleSelected(highlighted)
	}
	
    override func setSelected(selected: Bool, animated: Bool) {
		// don't call super
		styleSelected(selected)
	}

}

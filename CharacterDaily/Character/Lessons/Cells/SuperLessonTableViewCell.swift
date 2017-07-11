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
		self.backgroundColor = UIColor.clear
	
		textBoxView.layer.borderColor = Style.shared.lightBlue.cgColor
		textBoxView.layer.borderWidth = 1
		textBoxView.backgroundColor = UIColor.white
		
		cornerTitleLabel.backgroundColor = Style.shared.darkGray
		cornerTitleLabel.textColor = UIColor.white
		cornerTitleLabel.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P18)
		cornerTitleLabel.textAlignment = .center

		self.addSubview(textBoxView)
		self.sendSubview(toBack: textBoxView)
		self.addSubview(cornerTitleLabel)
	}
	
	override func layoutSubviews() {
		let pad:CGFloat = 15
		textBoxView.frame = CGRect(x: pad, y: pad,
		                               width: self.frame.size.width-pad*2, height: self.frame.size.height-pad*2)
		cornerTitleLabel.sizeToFit()
		let cornerW = cornerTitleLabel.frame.size.width*1.2
		cornerTitleLabel.frame = CGRect(x: textBoxView.frame.origin.x+textBoxView.frame.size.width - cornerW, y: pad,
		                                    width: cornerW, height: cornerTitleLabel.frame.size.height)
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
	
	func styleSelected(_ selected: Bool){
		if(selected){
			cornerTitleLabel.backgroundColor = Style.shared.lightBlue
			self.textLabel?.textColor = Style.shared.lightBlue
		}
		else{
			cornerTitleLabel.backgroundColor = Style.shared.darkGray
			self.textLabel?.textColor = UIColor.black
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		// don't call super
		styleSelected(highlighted)
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
		// don't call super
		styleSelected(selected)
	}

}

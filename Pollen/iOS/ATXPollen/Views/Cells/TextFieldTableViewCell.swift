//
//  TextFieldTableViewCell.swift
//  ATXPollen
//
//  Created by Robby Kraft on 7/13/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
	
	let textField = UITextField()

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
		textField.textAlignment = .right
		textField.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
		textField.textColor = UIColor.black
		self.addSubview(textField)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		textField.frame = CGRect(x: self.frame.size.width*0.5, y: 0, width: self.frame.size.width*0.5-20, height: self.frame.size.height)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

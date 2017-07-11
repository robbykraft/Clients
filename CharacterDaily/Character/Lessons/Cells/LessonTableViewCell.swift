//
//  LessonTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/12/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonTableViewCell: SuperLessonTableViewCell {
	
	var title:String?{
		didSet{
//			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 21)!,
//			                  NSKernAttributeName : CGFloat(4.0),
//			                  NSForegroundColorAttributeName : Style.shared.darkGray];
			if let titleString = title{
				let aText:NSMutableAttributedString = NSMutableAttributedString(string: titleString.uppercased())
				aText.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aText.length))
				self.textLabel?.attributedText = aText				
			}
		}
	}
	
    override func initUI() {
		super.initUI()
		cornerTitleLabel.text = "Daily Lesson"
		self.textLabel?.textColor = Style.shared.darkGray
		self.textLabel?.numberOfLines = 3
		self.imageView?.contentMode = .scaleAspectFill
		self.imageView?.clipsToBounds = true
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
		let PAD:CGFloat = 15.0
		
		let imgSize:CGFloat = min(self.frame.size.width*0.33 - 30,
		                          self.textBoxView.frame.size.height - 10.0)
		self.imageView?.frame = CGRect(x: 0, y: 0, width: imgSize, height: imgSize)
		self.imageView?.center = CGPoint(x: 8 + self.textBoxView.frame.origin.x + imgSize*0.5,
		                                     y: self.frame.size.height*0.5)
		self.textLabel?.frame = CGRect(x: self.frame.size.width*0.33 + 10, y: 0, width: self.frame.size.width*0.66 - PAD - 10, height: self.frame.size.height)
	}


//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

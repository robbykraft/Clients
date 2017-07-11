//
//  DateTableViewCell.swift
//  Lessons
//
//  Created by Robby
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {
	
	var dateLabel: UILabel = UILabel()
	
	var detailLabel: UILabel = UILabel()
	
	var dateText:String = ""{
		didSet{
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: Style.shared.P15)!,
			                  NSKernAttributeName : CGFloat(2.4),
			                  NSForegroundColorAttributeName : Style.shared.darkGray] as [String : Any];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: dateText)
			aText.addAttributes(attributes, range: NSMakeRange(0, aText.length))
			self.dateLabel.attributedText = aText
		}
	}
	var titleText:String = ""{
		didSet{
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: Style.shared.P15)!,
			                  NSKernAttributeName : CGFloat(2.4),
			                  NSForegroundColorAttributeName : Style.shared.gray] as [String : Any];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: titleText)
			aText.addAttributes(attributes, range: NSMakeRange(0, aText.length))
			self.textLabel?.attributedText = aText
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initUI()
	}
	
	func initUI(){
		self.addSubview(dateLabel)
		self.addSubview(detailLabel)
//		dateLabel.textColor = UIColor.darkGrayColor()
//		self.textLabel?.textColor = UIColor.grayColor()
		detailLabel.textColor = Style.shared.lightBlue
		detailLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.textLabel?.numberOfLines = 3
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad: CGFloat = 10.0
		let textPad: CGFloat = 20.0
		let extraRightPad: CGFloat = 80.0
		self.textLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 4 - pad - extraRightPad, height: self.frame.size.height*0.5)
		self.textLabel?.sizeToFit()
		self.textLabel?.frame = CGRect(x: 4 + textPad, y: self.frame.size.height*0.5 - 15,
		                               width: self.frame.size.width - 4 - textPad - extraRightPad,
		                               height: self.textLabel!.frame.size.height)
		self.dateLabel.frame = CGRect(x: 4 + textPad, y: self.frame.size.height*0.5 - 40,
		                              width: self.frame.size.width - 4 - textPad,
		                              height: 20)
		self.detailLabel.sizeToFit()
		let detailPad:CGFloat = 5
		self.detailLabel.frame = CGRect(x: self.frame.size.width - self.detailLabel.frame.size.width - detailPad,
		                               y: self.frame.size.height - self.detailLabel.frame.size.height - detailPad,
		                               width: self.detailLabel.frame.size.width,
		                               height: self.detailLabel.frame.size.height)
		
//		let imageFile:String = objectForRow["image"] as! String
//		cell.imageView?.imageFromStorageBucket(imageFile)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

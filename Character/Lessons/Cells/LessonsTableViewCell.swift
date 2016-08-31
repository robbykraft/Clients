//
//  LessonsTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/12/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonsTableViewCell: UITableViewCell {
	
	var dateLabel: UILabel = UILabel()
	
	var gradeLabel: UILabel = UILabel()
	
	var gradeLevel:Int = 0{
		didSet{
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: Style.shared.P12)!,
			                  NSKernAttributeName : CGFloat(2.4),
			                  NSForegroundColorAttributeName : Style.shared.gray];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: Character.shared.gradeNames[gradeLevel])
			aText.addAttributes(attributes, range: NSMakeRange(0, aText.length))
			self.gradeLabel.attributedText = aText
		}
	}
	
	var dateText:String = ""{
		didSet{
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: Style.shared.P15)!,
			                  NSKernAttributeName : CGFloat(2.4),
			                  NSForegroundColorAttributeName : Style.shared.darkGray];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: dateText)
			aText.addAttributes(attributes, range: NSMakeRange(0, aText.length))
			self.dateLabel.attributedText = aText
		}
	}
	var titleText:String = ""{
		didSet{
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: Style.shared.P15)!,
			                  NSKernAttributeName : CGFloat(2.4),
			                  NSForegroundColorAttributeName : Style.shared.gray];
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
		self.addSubview(gradeLabel)
//		dateLabel.textColor = UIColor.darkGrayColor()
//		self.textLabel?.textColor = UIColor.grayColor()
		self.textLabel?.numberOfLines = 3
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad: CGFloat = 10.0
		let textPad: CGFloat = 20.0
		let imgHeight = self.frame.size.height - CGFloat(pad*2.0)
		let imgWidth = imgHeight * 1.333
		self.imageView?.frame = CGRectMake(4, pad, imgWidth, imgHeight)
		self.textLabel?.frame = CGRectMake(0, 0, self.frame.size.width - imgWidth - 4 - pad, self.frame.size.height*0.5)
		self.textLabel?.sizeToFit()
		self.textLabel?.frame = CGRectMake(4 + imgWidth + textPad, self.frame.size.height*0.5 - 15,
		                                   self.frame.size.width - imgWidth - 4 - textPad,
		                                   self.textLabel!.frame.size.height)
		self.dateLabel.frame = CGRectMake(4 + imgWidth + textPad, self.frame.size.height*0.5 - 40,
		                                  self.frame.size.width - imgWidth - 4 - textPad,
		                                  20)
		self.gradeLabel.sizeToFit()
		let gradePad:CGFloat = 5
		self.gradeLabel.frame = CGRectMake(self.frame.size.width - self.gradeLabel.frame.size.width - gradePad,
		                                   self.frame.size.height - self.gradeLabel.frame.size.height - gradePad,
		                                   self.gradeLabel.frame.size.width,
		                                   self.gradeLabel.frame.size.height)
		
//		let imageFile:String = objectForRow["image"] as! String
//		cell.imageView?.imageFromStorageBucket(imageFile)
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

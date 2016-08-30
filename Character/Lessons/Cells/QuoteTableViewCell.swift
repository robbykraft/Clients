//
//  QuoteTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class QuoteTableViewCell: SuperLessonTableViewCell {

	let quoteMarkImage = UIImage.init(named: "quote-image")
	let quoteMarkImageView = UIImageView()
	
	override func initUI() {
		super.initUI()
		cornerTitleLabel.text = "Daily Quote"
//		self.textLabel?.font = UIFont.systemFontOfSize(15)
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: 16)
		self.textLabel?.numberOfLines = 4
		self.textLabel?.textColor = Style.shared.darkGray
		
		quoteMarkImageView.image = quoteMarkImage
		self.addSubview(quoteMarkImageView)
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
		let pad = self.textBoxView.frame.size.width*0.1
		quoteMarkImageView.frame = CGRectMake(0, 0, 30, 30)
		quoteMarkImageView.center = CGPointMake(self.frame.size.width*0.5,
		                                    quoteMarkImageView.frame.size.height*0.5 + self.textBoxView.frame.origin.y + 20)
		let textY:CGFloat = quoteMarkImageView.frame.origin.y + quoteMarkImageView.frame.size.height + 20
		self.textLabel?.frame = CGRectMake(self.textBoxView.frame.origin.x + pad, textY,
		                                   self.textBoxView.frame.size.width - pad*2, self.frame.size.height - textY)
		self.textLabel?.sizeToFit()
		self.textLabel?.frame = CGRectMake(self.textBoxView.frame.origin.x + pad, textY,
		                                   self.textBoxView.frame.size.width - pad*2, (self.textLabel?.frame.size.height)!)
	}

	override func styleSelected(selected: Bool) {
		super.styleSelected(selected)
		if(selected){
			quoteMarkImageView.image = quoteMarkImage?.imageWithTint(Style.shared.lightBlue)
		}
		else{
			quoteMarkImageView.image = quoteMarkImage
		}
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}

}

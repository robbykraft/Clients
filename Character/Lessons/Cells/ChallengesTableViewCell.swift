//
//  ChallengesTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ChallengesTableViewCell: SuperLessonTableViewCell {
	
	let viewChallengeLabel = UILabel()
	let completedLabel = UILabel()
	
	var numberCompleted:Int = 0{
		didSet{
			completedLabel.text = "\(numberCompleted)/3 TASKS COMPLETE"
		}
	}

	override func initUI() {
		super.initUI()
		
		cornerTitleLabel.text = "Daily Challenge"
		
		viewChallengeLabel.backgroundColor = Style.shared.lightBlue
		viewChallengeLabel.textColor = UIColor.whiteColor()
		viewChallengeLabel.textAlignment = .Center
		viewChallengeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		viewChallengeLabel.text = "My Challenges"
		
		completedLabel.textColor = UIColor.blackColor()
		completedLabel.text = "0/3 TASKS COMPLETE"
		
		self.addSubview(viewChallengeLabel)
		self.addSubview(completedLabel)
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
		viewChallengeLabel.sizeToFit()
		viewChallengeLabel.frame = CGRectMake(0, 0, self.textBoxView.frame.size.width*0.8, viewChallengeLabel.frame.size.height*1.2)
		viewChallengeLabel.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.4)
		completedLabel.sizeToFit()
		completedLabel.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.7)
	}

	override func styleSelected(selected: Bool) {
		super.styleSelected(selected)
		if(selected){
			completedLabel.textColor = Style.shared.lightBlue
		}
		else{
			completedLabel.textColor = UIColor.blackColor()
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

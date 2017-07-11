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
		
		cornerTitleLabel.text = "Daily Behavior"
		
		viewChallengeLabel.backgroundColor = Style.shared.lightBlue
		viewChallengeLabel.textColor = UIColor.white
		viewChallengeLabel.textAlignment = .center
		viewChallengeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		viewChallengeLabel.text = "My Challenges"
		
		completedLabel.textColor = UIColor.black
		completedLabel.text = "0/3 TASKS COMPLETE"
		completedLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		
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
		viewChallengeLabel.frame = CGRect(x: 0, y: 0, width: self.textBoxView.frame.size.width*0.8, height: viewChallengeLabel.frame.size.height*1.2)
		viewChallengeLabel.center = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.4)
		completedLabel.sizeToFit()
		completedLabel.center = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.7)
	}

	override func styleSelected(_ selected: Bool) {
		super.styleSelected(selected)
		if(selected){
			completedLabel.textColor = Style.shared.lightBlue
		}
		else{
			completedLabel.textColor = UIColor.black
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}

}

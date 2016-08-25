//
//  ChallengeTableViewCell.swift
//  Lessons
//
//  Created by Robby on 8/18/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ChallengeTableViewCell: UITableViewCell {

	let blueCircle = UIImageView()
	
	var completed:Bool = false{
		didSet{
			if(completed){
				blueCircle.image = UIImage(named: "circle-filled")?.imageWithTint(Style.shared.lightBlue)
			}
			else{
				blueCircle.image = UIImage(named: "circle-empty")?.imageWithTint(Style.shared.lightBlue)
			}
		}
	}
	
	func initUI() {
		self.textLabel?.text = "Acknowledge a student for telling the truth when they could have told a lie"
		self.textLabel?.textColor = Style.shared.darkGray
		self.textLabel?.numberOfLines = 4
		self.addSubview(blueCircle)
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
		let pad:CGFloat = 20
		self.textLabel?.frame = CGRectMake(self.frame.size.width * 0.33, pad, self.frame.size.width * 0.66 - pad, self.frame.size.height-pad*2)
		blueCircle.frame = CGRectMake(0, 0, self.frame.size.width * 0.18, self.frame.size.width * 0.18)
		blueCircle.center = CGPointMake(self.frame.size.width * 0.15 + 10, self.frame.size.height*0.5)
	}
	
	func styleSelected(selected: Bool) {
		if(selected){
			self.textLabel?.textColor = Style.shared.lightBlue
		}
		else{
			self.textLabel?.textColor = Style.shared.darkGray
		}
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
//		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
//		super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}

	
}

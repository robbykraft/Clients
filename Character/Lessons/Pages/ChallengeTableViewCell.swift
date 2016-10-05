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
		self.textLabel?.textColor = Style.shared.darkGray
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
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
		self.textLabel?.frame = CGRect(x: self.frame.size.width * 0.33, y: pad, width: self.frame.size.width * 0.66 - pad, height: self.frame.size.height-pad*2)
		blueCircle.frame = CGRect(x: 0, y: 0, width: self.frame.size.width * 0.18, height: self.frame.size.width * 0.18)
		blueCircle.center = CGPoint(x: self.frame.size.width * 0.15 + 10, y: self.frame.size.height*0.5)
	}
	
	func styleSelected(_ selected: Bool) {
		if(selected){
			self.textLabel?.textColor = Style.shared.lightBlue
		}
		else{
			self.textLabel?.textColor = Style.shared.darkGray
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//		super.setHighlighted(highlighted, animated: animated)
		styleSelected(highlighted)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
//		super.setSelected(selected, animated: animated)
		styleSelected(selected)
	}

	
}

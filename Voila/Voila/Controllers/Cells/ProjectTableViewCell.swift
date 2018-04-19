//
//  ProjectTableViewCell.swift
//  Voila
//
//  Created by Robby on 8/24/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
	
	var data:Project?{
		didSet{
			if let project = self.data{
				self.infoText.text = "\(project.furnitureCount()) items in \(project.rooms.count) rooms"
				self.textLabel?.text = project.name
				if(project.rooms.count == 1) { self.infoText.text = "\(project.rooms.count) room" }
				var proposalString = "not sent"
				self.proposalSentIndicator.backgroundColor = Style.shared.red
				self.proposalSentText.textColor = UIColor.white
				if let sent = project.proposalSent{
					let date = Date(timeIntervalSince1970: TimeInterval(sent))
					proposalString = Style.shared.dayStringForDateNoYear(date)
					self.proposalSentIndicator.backgroundColor = Style.shared.athensGray
					self.proposalSentText.textColor = UIColor.black
				}
				self.proposalSentText.text = proposalString
			}
		}
	}
	let infoText = UILabel()
	let proposalSentText = UILabel()
	
	let separator = UIView()
	
	let proposalSentIndicator = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.initUI()
    }
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.initUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}
	
	func initUI(){
		self.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		self.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		
		self.proposalSentIndicator.backgroundColor = UIColor.lightGray
		
		self.infoText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.infoText.numberOfLines = 2
		self.infoText.textColor = UIColor.gray

		self.proposalSentText.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P12)
		self.proposalSentText.textColor = UIColor.black

		self.backgroundColor = .white

		self.separator.backgroundColor = UIColor.lightGray
		self.addSubview(self.proposalSentIndicator)
		self.addSubview(self.infoText)
		self.addSubview(self.separator)
		self.addSubview(self.proposalSentText)
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = Style.shared.cellSelectionColor
		self.selectedBackgroundView = bgColorView
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let PAD:CGFloat = 10;
		let size = self.frame.size
		if let textLabel = self.textLabel{
			textLabel.sizeToFit()
			textLabel.frame = CGRect(x: PAD, y: PAD*0.5, width: textLabel.frame.size.width, height: textLabel.frame.size.height)
		}

		self.proposalSentIndicator.frame = CGRect(x: self.frame.size.width-30, y: 0, width: 30, height: self.frame.size.height)
		
		self.infoText.sizeToFit()
		self.infoText.frame = CGRect(x: PAD*2, y:  PAD*0.5 + self.textLabel!.frame.size.height, width: self.infoText.frame.size.width, height: self.infoText.frame.size.height)
		
		self.proposalSentText.sizeToFit()
		self.proposalSentText.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		self.proposalSentText.transform = CGAffineTransform.init(rotationAngle: -1.5708)
		self.proposalSentText.center = self.proposalSentIndicator.center

		self.separator.frame = CGRect(x: 0, y: size.height-1, width: size.width, height: 1)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		self.separator.backgroundColor = UIColor.lightGray
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		self.separator.backgroundColor = UIColor.lightGray
	}
}

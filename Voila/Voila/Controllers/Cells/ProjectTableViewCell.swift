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
				self.infoText.text = "\(project.rooms.count) rooms\n\(project.furnitureCount()) items"
				self.textLabel?.text = project.name
				if(project.rooms.count == 1) { self.infoText.text = "\(project.rooms.count) room" }
				var emailString = "✗ Email"
				var proposalString = "✗ Proposal Sent"
				if project.email != nil && project.email! != ""{
					emailString = "✓ Email"
				}
//				if project.email != nil && project.email! != ""{
//					emailString = "✓ Email"
//				}
				self.tasksText.text = emailString + "\n" + proposalString
			}
		}
	}
	let infoText = UILabel()
	let tasksText = UILabel()
	
	let separator = UIView()

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
		
		self.infoText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.infoText.numberOfLines = 2
		self.infoText.textColor = UIColor.gray

		self.tasksText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
		self.tasksText.numberOfLines = 3
		self.tasksText.textColor = UIColor.gray

		self.separator.backgroundColor = UIColor.lightGray
		self.addSubview(self.infoText)
		self.addSubview(self.separator)
		self.addSubview(self.tasksText)
		
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

		self.infoText.sizeToFit()
		self.infoText.frame = CGRect(x: PAD*2, y:  PAD*0.5 + self.textLabel!.frame.size.height, width: self.infoText.frame.size.width, height: self.infoText.frame.size.height)
		
		self.tasksText.sizeToFit()
		self.tasksText.frame = CGRect(x: size.width*0.5, y: PAD*0.5 + self.textLabel!.frame.size.height, width: size.width*0.5-PAD, height: self.tasksText.frame.size.height)
		
		self.separator.frame = CGRect(x: PAD, y: size.height-1, width: size.width-PAD*2, height: 1)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		self.separator.backgroundColor = UIColor.lightGray
//		let color = yourView.backgroundColor
//		
//		if(selected) {
//			yourView.backgroundColor = color
//		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//		let color = yourView.backgroundColor
		super.setHighlighted(highlighted, animated: animated)
		self.separator.backgroundColor = UIColor.lightGray
		
//		if(highlighted) {
//			yourView.backgroundColor = color
//		}
	}
}

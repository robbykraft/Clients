//
//  CompletedQuestionView.swift
//  Character
//
//  Created by Robby on 3/26/17.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit
import Firebase

protocol CompletedQuestionDelegate: class {
	func didChangeCompleted(sender: CompletedQuestionView)
}

class CompletedQuestionView: UIView {
	
	weak var delegate:CompletedQuestionDelegate? // for calling completed button press function
	
	let blueCircle = UIImageView()
	let textLabel:UILabel = UILabel()
	let button:UIButton = UIButton()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}

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
		self.textLabel.textColor = Style.shared.darkGray
		self.textLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		self.textLabel.numberOfLines = 4
		self.textLabel.text = "I completed this challenge by sharing this"
		self.addSubview(textLabel)

		blueCircle.image = UIImage(named: "circle-empty")?.imageWithTint(Style.shared.lightBlue)
		self.addSubview(blueCircle)
		
		button.backgroundColor = UIColor.clear
		button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
		self.addSubview(button)
	}
	
	func didPressButton() {
		completed = !completed
		if let d = delegate{
			d.didChangeCompleted(sender: self)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad:CGFloat = 20
		self.textLabel.frame = CGRect(x: self.frame.size.width * 0.33, y: pad, width: self.frame.size.width * 0.66 - pad, height: self.frame.size.height-pad*2)
		blueCircle.frame = CGRect(x: 0, y: 0, width: self.frame.size.width * 0.18, height: self.frame.size.width * 0.18)
		blueCircle.center = CGPoint(x: self.frame.size.width * 0.15 + 10, y: self.frame.size.height*0.5)
		button.frame = self.bounds
	}
}

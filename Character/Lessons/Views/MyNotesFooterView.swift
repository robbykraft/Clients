//
//  CompletedQuestionView.swift
//  Character
//
//  Created by Robby on 3/26/17.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit
import Firebase

protocol MyNotesFooterDelegate: class {
	func didPressNotesButton(sender: MyNotesFooterView)
}

class MyNotesFooterView: UIView {
	
	weak var delegate:MyNotesFooterDelegate? // for calling completed button press function
	
	let paperclipImage = UIImageView()
	let textLabel:UILabel = UILabel()
	
	let topHR = UIView()
	let bottomHR = UIView()
	
	let button:UIButton = UIButton()
	var noun:String?{
		didSet{
//			if let nounString = noun{
//				textLabel.text = "I've shared this " + nounString + " with the class"
//			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initUI()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initUI()
	}

	var hasNotes:Bool = false{
		didSet{
			if(hasNotes){
				paperclipImage.image = UIImage(named: "paper-clip")?.imageWithTint(Style.shared.lightBlue)
			}
			else{
				paperclipImage.image = UIImage(named: "paper-clip")?.imageWithTint(UIColor.black)
			}
		}
	}
	
	func initUI() {
		topHR.backgroundColor = Style.shared.darkGray
		bottomHR.backgroundColor = Style.shared.darkGray
		self.addSubview(topHR)
		self.addSubview(bottomHR)
		
		self.textLabel.textColor = UIColor.black
		self.textLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
		self.textLabel.text = "my notes for this lesson"
		self.addSubview(textLabel)

		paperclipImage.image = UIImage(named: "paper-clip")?.imageWithTint(UIColor.black)
		self.addSubview(paperclipImage)
		
		button.backgroundColor = UIColor.clear
		button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
		self.addSubview(button)
	}
	
	func didPressButton() {
		hasNotes = !hasNotes
		if let d = delegate{
			d.didPressNotesButton(sender: self)
		}
		// todo: report to the database
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad:CGFloat = 20
		let imageWidth:CGFloat = self.frame.size.height*0.66
		topHR.frame = CGRect(x: pad, y:0, width:self.frame.size.width-pad*2, height:1)
		bottomHR.frame = CGRect(x: pad, y:self.frame.size.height-1, width:self.frame.size.width-pad*2, height:1)
		self.textLabel.frame = CGRect(x: imageWidth + pad*3, y: 0, width: self.frame.size.width - imageWidth - pad*4, height: self.frame.size.height)
		paperclipImage.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)
		paperclipImage.center = CGPoint(x: imageWidth*0.5 + pad*2, y: self.frame.size.height*0.5)
		button.frame = self.bounds
	}
}

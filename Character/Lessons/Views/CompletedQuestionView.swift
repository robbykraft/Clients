//
//  CompletedQuestionView.swift
//  Character
//
//  Created by Robby on 3/26/17.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit
import Firebase

class CompletedQuestionView: UIView {
	
	let blueCircle = UIImageView()
	let textLabel:UILabel = UILabel()
	var noun:String?{
		didSet{
			if let nounString = noun{
				textLabel.text = "I've shared this " + nounString + " with the class"
			}
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
		self.textLabel.text = "I've shared this with the class"
		self.addSubview(textLabel)

		blueCircle.image = UIImage(named: "circle-filled")?.imageWithTint(Style.shared.lightBlue)
		self.addSubview(blueCircle)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let pad:CGFloat = 20
		self.textLabel.frame = CGRect(x: self.frame.size.width * 0.33, y: pad, width: self.frame.size.width * 0.66 - pad, height: self.frame.size.height-pad*2)
		blueCircle.frame = CGRect(x: 0, y: 0, width: self.frame.size.width * 0.18, height: self.frame.size.width * 0.18)
		blueCircle.center = CGPoint(x: self.frame.size.width * 0.15 + 10, y: self.frame.size.height*0.5)
	}
	

}

//
//class CompletedQuestionView: UIView {
//	
//	let checkBox:UILabel = UILabel()
//	let questionText:UILabel = UILabel()
//	var noun:String?{
//		didSet{
//			if let nounString = noun{
//				questionText.text = "I've shared this " + nounString + " with the class"
//			}
//		}
//	}
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		self.initUI()
//	}
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		self.initUI()
//	}
//	
//	func initUI() {
//		questionText.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P18)
//		questionText.textColor = UIColor.black
//		questionText.text = "I've shared this with the class"
//		questionText.numberOfLines = 2
//		
//		checkBox.text = "❎"  // ✅
//		checkBox.textAlignment = .center
//		checkBox.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P40)
//		
//		self.addSubview(questionText)
//		self.addSubview(checkBox)
//		
//	}
//	
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		questionText.frame = CGRect.init(x: 75, y: 0, width: self.frame.size.width-100, height: 50)
//		checkBox.frame = CGRect.init(x: 0, y: 0, width: 75, height: 75)
//	}
//}



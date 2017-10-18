//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class QueryView: UIView {
	
	var slides:[QuerySlide] = []
	let queryDoneButton = UIButton()
	
	let dateLabel = UILabel()
	

	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	func initUI(){

		dateLabel.textColor = Style.shared.blue
		dateLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
		self.addSubview(dateLabel)

		let sevenDwarfs = ["Congestion", "Runny", "Itchy", "Sneezy", "Sleepy"]
		for i in 0..<5{
			let slide = QuerySlide()
			slide.coverText.text = sevenDwarfs[i]
//			slide.coverButton.backgroundColor = UIColor(hue: CGFloat(i)/5, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			self.addSubview(slide)
			self.slides.append(slide)
		}
		
		queryDoneButton.setTitle("Done", for: .normal)
		queryDoneButton.setTitleColor(Style.shared.blue, for: .normal)
		queryDoneButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		queryDoneButton.layer.cornerRadius = 20
		queryDoneButton.layer.borderColor = Style.shared.blue.cgColor
		queryDoneButton.layer.borderWidth = 4
		queryDoneButton.sizeToFit()
		queryDoneButton.frame = CGRect(x: 0, y: 0, width: queryDoneButton.frame.size.width*2, height: queryDoneButton.frame.size.height*1.5)
		self.addSubview(queryDoneButton)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		dateLabel.text = dateFormatter.string(from: Date())
		dateLabel.sizeToFit()
		dateLabel.center = CGPoint(x: self.bounds.size.width*0.5, y: dateLabel.frame.size.height*0.5)

		for i in 0..<slides.count{
			let pad:CGFloat = 5.0
			let h:CGFloat = self.bounds.size.height/7
			slides[i].frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: h)
			slides[i].center = CGPoint(x: self.center.x, y: dateLabel.frame.size.height + 15 + h*0.5 + (h+pad)*CGFloat(i))
		}
		queryDoneButton.center = CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height - queryDoneButton.frame.size.height*0.5 - 20)
	}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

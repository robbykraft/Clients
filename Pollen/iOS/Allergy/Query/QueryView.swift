//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class QueryView: UIView {
	
	let scrollView = MainScrollView()
	
	var slides:[QuerySlide] = []
	let queryDoneButton = UIButton()
	
	let dateLabel = UILabel()
	
	let topQuestionLabel = UILabel()
	

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
		
		self.scrollView.isPagingEnabled = true
		self.scrollView.delaysContentTouches = false
		self.scrollView.showsHorizontalScrollIndicator = false
		self.addSubview(self.scrollView)
		
		dateLabel.textColor = Style.shared.blue
		dateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		self.scrollView.addSubview(dateLabel)
		
		topQuestionLabel.textColor = Style.shared.blue
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		topQuestionLabel.text = "What is bothering you today?"
		self.scrollView.addSubview(topQuestionLabel)

		let sevenDwarfs = ["Congestion", "Runny", "Itchy", "Sneezy", "Sleepy"]
		for i in 0..<5{
			let slide = QuerySlide()
			slide.coverText.text = sevenDwarfs[i]
//			slide.coverButton.backgroundColor = UIColor(hue: CGFloat(i)/5, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			self.scrollView.addSubview(slide)
			self.slides.append(slide)
		}
		
		queryDoneButton.setTitle("Done", for: .normal)
		queryDoneButton.setTitleColor(Style.shared.blue, for: .normal)
		queryDoneButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		queryDoneButton.layer.cornerRadius = 20
		queryDoneButton.layer.backgroundColor = UIColor.white.cgColor
		queryDoneButton.layer.borderColor = Style.shared.blue.cgColor
		queryDoneButton.layer.borderWidth = 4
		queryDoneButton.sizeToFit()
		queryDoneButton.frame = CGRect(x: 0, y: 0, width: queryDoneButton.frame.size.width*2, height: queryDoneButton.frame.size.height*1.5)
		self.scrollView.addSubview(queryDoneButton)
		
		queryDoneButton.addTarget(self, action: #selector(doneButtonHandler), for: .touchUpInside)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDown)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDragEnter)
		
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragOutside)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchCancel)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragExit)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchUpInside)

	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let w:CGFloat = self.frame.size.width

		self.scrollView.frame = self.bounds
		self.scrollView.contentSize = CGSize(width: self.bounds.width*3, height: self.bounds.height)
		self.scrollView.contentOffset = CGPoint(x: w, y: 0)

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		dateLabel.text = dateFormatter.string(from: Date())
		dateLabel.sizeToFit()
		dateLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.size.height*0.5)

		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.origin.y + dateLabel.frame.size.height + topQuestionLabel.frame.size.height*0.5 + 10)
		
		let yTop:CGFloat = topQuestionLabel.frame.origin.y + topQuestionLabel.frame.size.height
		let questionFrame = CGRect(x: 0, y: yTop + 15, width: self.bounds.size.width, height: self.bounds.size.height - yTop - queryDoneButton.frame.size.height - 15 - 20 - 10)
		
		for i in 0..<slides.count{
			let pad:CGFloat = 5.0
			let h:CGFloat = (questionFrame.size.height-pad*5)/5
			slides[i].frame = CGRect(x: w + 0, y: 0, width: self.bounds.size.width, height: h)
			slides[i].center = CGPoint(x: w + self.center.x, y: questionFrame.origin.y + h*0.5 + (h+pad)*CGFloat(i))
		}
		queryDoneButton.center = CGPoint(x: w + self.bounds.size.width*0.5, y: self.bounds.size.height - queryDoneButton.frame.size.height*0.5 - 20)
	}
	
	func doneButtonHandler(){
		
	}
	
	func doneButtonSetSelected(){
		self.queryDoneButton.layer.backgroundColor = Style.shared.blue.cgColor
		queryDoneButton.setTitleColor(UIColor.white, for: .normal)
	}
	func doneButtonSetUnselected(){
		self.queryDoneButton.layer.backgroundColor = UIColor.white.cgColor
		queryDoneButton.setTitleColor(Style.shared.blue, for: .normal)
	}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

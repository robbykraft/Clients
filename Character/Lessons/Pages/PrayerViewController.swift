//
//  PrayerViewController.swift
//  Character
//
//  Created by Robby on 8/30/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class PrayerViewController: UIViewController {
	
	var data: Lesson?{
		didSet{
		}
	}
	
	let prayerBodyView = UITextView()
	
	let scrollView = UIScrollView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.frame = self.view.frame
		self.view = scrollView
		self.view.backgroundColor = UIColor.white
		
		prayerBodyView.isScrollEnabled = false;
		prayerBodyView.isEditable = false
		prayerBodyView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		prayerBodyView.text = "Dear God,\n \nThank you for this new day.\nHelp me to be a person of character and follow Your way,\n \nto be worthy of trust,\nto be respectful and responsible, doing what I must.\n \nHelp me to act with fairness, show that I care,\nbe a good citizen, and always live this prayer.\n \nAmen."
		
		self.view.addSubview(prayerBodyView)
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		let topPad:CGFloat = 20
		// FRAME SETTING
		// PRAYER BODY
		prayerBodyView.frame = CGRect(x: sidePad, y: topPad,
		                                 width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		prayerBodyView.sizeToFit()
		let prayerBodyHeight = prayerBodyView.frame.size.height
		prayerBodyView.frame = CGRect(x: sidePad, y: topPad,
		                                 width: self.view.frame.size.width - sidePad*2, height: prayerBodyHeight)
		
//		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: prayerBodyHeight + topPad)

		// CHALLENGE QUESTION FOOTER
		var questionFooter:CompletedQuestionView
		questionFooter = CompletedQuestionView.init(frame: CGRect.init(x: 0, y: prayerBodyHeight + topPad + 20, width: self.view.frame.size.width, height: 120))
		questionFooter.noun = "daily behavior"
		self.view.addSubview(questionFooter)
		
		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: prayerBodyHeight + topPad + 20 + questionFooter.frame.size.height + 20)

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}

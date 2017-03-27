//
//  PrayerViewController.swift
//  Character
//
//  Created by Robby on 8/30/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class PledgeViewController: UIViewController, CompletedQuestionDelegate{
	
	var data: Lesson?{
		didSet{
			getCompletionState()
		}
	}
	
	let pledgeBodyView = UITextView()
	
	let scrollView = UIScrollView()

	let questionFooter = CompletedQuestionView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.frame = self.view.frame
		self.view = scrollView
		self.view.backgroundColor = UIColor.white
		
		pledgeBodyView.isScrollEnabled = false;
		pledgeBodyView.isEditable = false
		pledgeBodyView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		pledgeBodyView.text = "I am grateful for this day.\nI pledge to be a person of character in every way.\nI will be worthy of trust.\nI will be respectful and responsible doing what I must.\nI will always act with fairness.\nI will show that I care.\nI will be a good citizen and always do my share."
		
//		pledgeBodyView.text = "Dear God,\n \nThank you for this new day.\nHelp me to be a person of character and follow Your way,\n \nto be worthy of trust,\nto be respectful and responsible, doing what I must.\n \nHelp me to act with fairness, show that I care,\nbe a good citizen, and always live this prayer.\n \nAmen."
		
		self.view.addSubview(pledgeBodyView)
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		let topPad:CGFloat = 20
		// FRAME SETTING
		// PLEDGE BODY
		pledgeBodyView.frame = CGRect(x: sidePad, y: topPad,
		                                 width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		pledgeBodyView.sizeToFit()
		let pledgeBodyHeight = pledgeBodyView.frame.size.height
		pledgeBodyView.frame = CGRect(x: sidePad, y: topPad,
		                                 width: self.view.frame.size.width - sidePad*2, height: pledgeBodyHeight)
		
//		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: prayerBodyHeight + topPad)

		// CHALLENGE QUESTION FOOTER
		questionFooter.frame = CGRect.init(x: 0, y: pledgeBodyHeight + topPad + 20, width: self.view.frame.size.width, height: 120)
		questionFooter.noun = "pledge"
		questionFooter.delegate = self
		self.view.addSubview(questionFooter)
		
		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: pledgeBodyHeight + topPad + 20 + questionFooter.frame.size.height + 20)

	}
	
	func getCompletionState(){
		Fire.shared.getUser { (uid, userData) in
			if let userDatabase = userData{
				if let challenges = userDatabase["challenges"]{
					// todo; weird fix here
					if let lessonData = self.data{
						if let date = lessonData.date{
							let dateStamp = Int(date.timeIntervalSince1970)
							if let first = challenges["\(dateStamp)"] as? [String:Any]{
								if let completedState:Bool = first["pledge"] as? Bool{
									self.questionFooter.completed = completedState
								}
							}
						}
					}
				}
			}
		}
	}

	func challengeURLString() -> String?{
		if let lessonData = self.data{
			if let date = lessonData.date{
				let dateStamp = Int(date.timeIntervalSince1970)
				let urlString:String = "\(dateStamp)" + "/pledge"
				return urlString
			}
		}
		return nil
	}
	
	func didChangeCompleted(sender: CompletedQuestionView) {
		if let urlString = challengeURLString(){
			Character.shared.updateChallengeCompletion(urlString, didComplete: sender.completed, completionHandler: nil)
		}
	}

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}

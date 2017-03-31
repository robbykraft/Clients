//
//  ChallengesViewController.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class BehaviorViewController: UIViewController, CompletedQuestionDelegate {
	
	var data: Lesson?{
		didSet{
			if let behaviorText = data?.behavior{
				behaviorBodyView.text = behaviorText
			}
			getCompletionState()
		}
	}
	
	let behaviorBodyView = UITextView()
	
	let scrollView = UIScrollView()

	let questionFooter = CompletedQuestionView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// NAVIGATION RIGHT BUTTON
		let rightButton:UIBarButtonItem = UIBarButtonItem.init(title: "•••", style: .plain, target: self, action: #selector(rightButtonPressed))
		self.navigationItem.rightBarButtonItem = rightButton;

		
		scrollView.frame = self.view.frame
		self.view = scrollView
		self.view.backgroundColor = UIColor.white
		
		behaviorBodyView.isScrollEnabled = false;
		behaviorBodyView.isEditable = false
		behaviorBodyView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		
		self.view.addSubview(behaviorBodyView)
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		let topPad:CGFloat = 20
		// FRAME SETTING
		// BEHAVIOR BODY
		behaviorBodyView.frame = CGRect(x: sidePad, y: topPad,
		                              width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		behaviorBodyView.sizeToFit()
		let behaviorBodyHeight = behaviorBodyView.frame.size.height
		behaviorBodyView.frame = CGRect(x: sidePad, y: topPad,
		                              width: self.view.frame.size.width - sidePad*2, height: behaviorBodyHeight)
		
//		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: prayerBodyHeight + topPad)
		
		// CHALLENGE QUESTION FOOTER
		questionFooter.frame = CGRect.init(x: 0, y: behaviorBodyHeight + topPad + 20, width: self.view.frame.size.width, height: 120)
		questionFooter.noun = "behavior"
		questionFooter.delegate = self
		self.view.addSubview(questionFooter)
		
		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: behaviorBodyHeight + topPad + 20 + questionFooter.frame.size.height + 20)
		
	}
	
	func getCompletionState(){
		Fire.shared.getUser { (uid, userData) in
			if let userDatabase = userData{
				if let challenges = userDatabase["challenges"]{
//					if let urlString = self.challengeURLString(){
						// todo; weird fix here
						if let lessonData = self.data{
							if let date = lessonData.date{
								let dateStamp = Int(date.timeIntervalSince1970)
								if let first = challenges["\(dateStamp)"] as? [String:Any]{
									if let completedState:Bool = first["behavior"] as? Bool{
										self.questionFooter.completed = completedState
									}
								}
							}
						}
//					}
				}
			}
		}
	}
	
	func challengeURLString() -> String?{
		if let lessonData = self.data{
			if let date = lessonData.date{
				let dateStamp = Int(date.timeIntervalSince1970)
				let urlString:String = "\(dateStamp)" + "/behavior"
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

	func rightButtonPressed(){
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Leave Feedback", style: .default , handler:{ (UIAlertAction)in
			let vc = FeedbackViewController()
			// todo: this needs a more proper pointer to the datbase object
			vc.feedbackTarget = self.challengeURLString()
			self.navigationController?.pushViewController(vc, animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Submit a Behavior", style: .default , handler:{ (UIAlertAction)in
			
		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:{ (UIAlertAction)in
			
		}))
		self.present(alert, animated: true) { }
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

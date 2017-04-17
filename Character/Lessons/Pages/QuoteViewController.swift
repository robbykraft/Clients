//
//  QuoteViewController.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController, CompletedQuestionDelegate {

	var data: Lesson?{
		didSet{
			quoteBodyView.text = data?.quote
			quoteAuthorLabel.text = data?.quoteAuthor
			getCompletionState()
		}
	}
	
	let quoteMarkImageView = UIImageView()
	
	let quoteBodyView = UITextView()
	let quoteAuthorLabel = UILabel()
	
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
		
		quoteMarkImageView.image = UIImage.init(named: "quote-image")

		quoteBodyView.isScrollEnabled = false;
		quoteBodyView.isEditable = false
		quoteBodyView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		quoteAuthorLabel.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P24)
		quoteAuthorLabel.textAlignment = .center
		quoteAuthorLabel.numberOfLines = 0
		quoteAuthorLabel.textColor = Style.shared.lightBlue
		
		self.view.addSubview(quoteMarkImageView)
		self.view.addSubview(quoteBodyView)
		self.view.addSubview(quoteAuthorLabel)
		
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		
		// FRAME SETTING
		// QUOTE MARK
		quoteMarkImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		quoteMarkImageView.center = CGPoint(x: self.view.frame.size.width*0.5, y: 70)
		let imgHeight = quoteMarkImageView.frame.origin.y + quoteMarkImageView.frame.size.height

		// QUOTE BODY
		quoteBodyView.frame = CGRect(x: sidePad, y: imgHeight + 20,
		                                 width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		quoteBodyView.sizeToFit()
		let quoteBodyHeight = quoteBodyView.frame.size.height
		quoteBodyView.frame = CGRect(x: sidePad, y: imgHeight + 20,
		                                 width: self.view.frame.size.width - sidePad*2, height: quoteBodyHeight)
		
		// AUTHOR LABEL
		quoteAuthorLabel.frame = CGRect(x: sidePad, y: quoteBodyView.frame.origin.y + quoteBodyHeight + 20, width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		quoteAuthorLabel.sizeToFit()
		let authorHeight = quoteAuthorLabel.frame.size.height
		quoteAuthorLabel.frame = CGRect(x: sidePad, y: quoteBodyView.frame.origin.y + quoteBodyHeight + 20, width: self.view.frame.size.width - sidePad*2, height: authorHeight)
		
//		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: quoteAuthorLabel.frame.origin.y + authorHeight + 20)
		
		// CHALLENGE QUESTION FOOTER
		questionFooter.frame = CGRect.init(x: 0, y: quoteAuthorLabel.frame.origin.y + authorHeight + 20, width: self.view.frame.size.width, height: 120)
		questionFooter.textLabel.text = "I completed this challenge by sharing this quote"
		questionFooter.delegate = self
		self.view.addSubview(questionFooter)
		
		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: quoteAuthorLabel.frame.origin.y + authorHeight + 20 + questionFooter.frame.size.height + 20)

    }
	
	func getCompletionState(){
		Fire.shared.getUser { (uid, userData) in
			if let userDatabase = userData{
				if let challenges = userDatabase["challenges"]{
					if let urlString = self.challengeURLString(){
						if let completedState:Bool = challenges[urlString] as? Bool{
							self.questionFooter.completed = completedState
						}
					}
				}
			}
		}
	}

	func challengeURLString() -> String?{
		if let lessonData = self.data{
			if let quoteKey = lessonData.quoteKey{
				return quoteKey
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
			vc.feedbackTargetKey = self.challengeURLString()
			vc.feedbackTargetType = "quotes"
			self.navigationController?.pushViewController(vc, animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Submit a Quote", style: .default , handler:{ (UIAlertAction)in
			let vc = CreateQuoteViewController()
			self.navigationController?.present(vc, animated: true, completion: nil)

		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:{ (UIAlertAction)in
			
		}))
		self.present(alert, animated: true) { }
	}

	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

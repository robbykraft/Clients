//
//  ViewController.swift
//  Lessons
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonViewController: UIViewController, CompletedQuestionDelegate {
	
	var data:Lesson?{
		didSet{
			let title:String = (data?.title)!
			let body:String = (data?.body)!
			let author:String = (data?.author)!

			let imageFilename = (data?.image)!
			Cache.shared.imageFromStorageBucket(imageFilename) { (image, requiredDownload) in
				self.imageView.image = image
			}
			
//			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 21)!,
//			                  NSKernAttributeName : CGFloat(4.0),
//			                  NSForegroundColorAttributeName : Style.shared.darkGray];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: title.uppercased())
			aText.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aText.length))
			self.titleLabel.numberOfLines = 0
			self.titleLabel.attributedText = aText
			
			bodyText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			bodyText.text = body
			
			authorLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			authorLabel.text = author

			getCompletionState()
		}
	}
	
	let imageView = UIImageView()
	let authorLabel = UILabel()
	let bodyText = UITextView()
	let titleLabel = UILabel()

	let authorHR1 = UIView()
	let authorHR2 = UIView()
	
	let scrollView = UIScrollView()
	
	let questionFooter = CompletedQuestionView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// NAVIGATION RIGHT BUTTON
		let rightButton:UIBarButtonItem = UIBarButtonItem.init(title: "•••", style: .plain, target: self, action: #selector(rightButtonPressed))
		self.navigationItem.rightBarButtonItem = rightButton;
		
		let navPad:CGFloat = 0//self.navigationController!.navigationBar.frame.size.height
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		
		scrollView.frame = self.view.frame
		self.view = scrollView
		
		self.view.backgroundColor = UIColor.white
		
		self.view.addSubview(imageView)
		self.view.addSubview(authorLabel)
		self.view.addSubview(bodyText)
		self.view.addSubview(titleLabel)
		self.view.addSubview(authorHR1)
		self.view.addSubview(authorHR2)
		
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		authorLabel.numberOfLines = 0
		authorLabel.textAlignment = .center
		authorLabel.textColor = Style.shared.lightBlue
		bodyText.isScrollEnabled = false
		bodyText.isEditable = false
		bodyText.dataDetectorTypes = .link
		authorHR1.backgroundColor = UIColor.black
		authorHR2.backgroundColor = UIColor.black
		
		// FRAME SETTING
		// IMAGE VIEW
		let imgHeight:CGFloat = self.view.frame.size.width * 175.0/300.0
		imageView.frame = CGRect(x: 0, y: navPad, width: self.view.frame.size.width, height: imgHeight)
		
		// TITLE LABEL
		titleLabel.frame = CGRect(x: sidePad, y: navPad + imgHeight + 20, width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		titleLabel.sizeToFit()
		let titleHeight = titleLabel.frame.size.height
		titleLabel.frame = CGRect(x: sidePad, y: navPad + imgHeight + 20, width: self.view.frame.size.width - sidePad*2, height: titleHeight)
		
		// AUTHOR LABEL
		authorLabel.frame = CGRect(x: sidePad, y: titleLabel.frame.origin.y + titleHeight + 20, width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		authorLabel.sizeToFit()
		let authorHeight = authorLabel.frame.size.height
		authorLabel.frame = CGRect(x: sidePad, y: titleLabel.frame.origin.y + titleHeight + 20, width: self.view.frame.size.width - sidePad*2, height: authorHeight)
		
		// LESSON BODY
		bodyText.frame = CGRect(x: sidePad, y: authorLabel.frame.origin.y + authorHeight + 20, width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
		bodyText.sizeToFit()
		let bodyHeight = bodyText.frame.size.height
		
		authorHR1.frame = CGRect(x: sidePad, y: authorLabel.frame.origin.y - 10, width: self.view.frame.size.width - sidePad*2, height: 1)
		authorHR2.frame = CGRect(x: sidePad, y: authorLabel.frame.origin.y + authorHeight + 10, width: self.view.frame.size.width - sidePad*2, height: 1)
		
//		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: bodyText.frame.origin.y + bodyHeight + 20)
		
		let notesFooter = MyNotesFooterView()
		notesFooter.frame = CGRect.init(x: 0, y: bodyText.frame.origin.y + bodyHeight + 20, width: self.view.frame.size.width, height: 40)
		self.view.addSubview(notesFooter)

		questionFooter.frame = CGRect.init(x: 0, y: bodyText.frame.origin.y + bodyHeight + 20 + notesFooter.frame.size.height + 20, width: self.view.frame.size.width, height: 120)
		questionFooter.noun = "lesson"
		questionFooter.delegate = self
		self.view.addSubview(questionFooter)

		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: bodyText.frame.origin.y + bodyHeight + 20 + questionFooter.frame.size.height + 20 + notesFooter.frame.size.height + 20)

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
			if let lessonKey = lessonData.lessonKey{
				return lessonKey
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
			vc.feedbackTarget = self.challengeURLString()
			self.navigationController?.pushViewController(vc, animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Submit a Lesson", style: .default , handler:{ (UIAlertAction)in
			
		}))
		alert.addAction(UIAlertAction(title: "Print", style: .default , handler:{ (UIAlertAction)in
			
		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:nil))
		self.present(alert, animated: true) { }
	}

}


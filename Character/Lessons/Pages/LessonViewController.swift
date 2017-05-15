//
//  ViewController.swift
//  Lessons
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonViewController: UIViewController, CompletedQuestionDelegate, MyNotesFooterDelegate {
	
	var data:Lesson?{
		didSet{
			let title:String = (data?.title)!
			let body:String = (data?.body)!
			let author:String = (data?.author)!

			let imageFilename = (data?.image)!
			Cache.shared.imageFromStorageBucket(imageFilename) { (image, requiredDownload) in
				self.imageView.image = image
			}
			// QUICK FIX for JPG / JPEG file name differences
			let filename: NSString = imageFilename as NSString
			let pathPrefix = filename.deletingPathExtension
			let alternateFileName = pathPrefix + ".jpeg"
			Cache.shared.imageFromStorageBucket(alternateFileName, completionHandler: { (image, didRequireDownload) in
				print("cache return")
				self.imageView.image = image
			})
			
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
			
			getHasNotes()
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
	let notesFooter = MyNotesFooterView()
	
	var myLessonNotesString:String? // hang onto my notes for this lesson
	
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
		
		notesFooter.frame = CGRect.init(x: 0, y: bodyText.frame.origin.y + bodyHeight + 20, width: self.view.frame.size.width, height: 40)
		notesFooter.delegate = self
		self.view.addSubview(notesFooter)

		questionFooter.frame = CGRect.init(x: 0, y: bodyText.frame.origin.y + bodyHeight + 20 + notesFooter.frame.size.height + 20, width: self.view.frame.size.width, height: 120)
		questionFooter.textLabel.text = "I completed this challenge by sharing this lesson"
		questionFooter.delegate = self
		self.view.addSubview(questionFooter)

		scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: bodyText.frame.origin.y + bodyHeight + 20 + questionFooter.frame.size.height + 20 + notesFooter.frame.size.height + 20)

	}
	
	override func viewDidAppear(_ animated: Bool) {
		getHasNotes()
	}
	
	func getHasNotes(){
		Fire.shared.getUser { (uid, userData) in
			if let userDatabase = userData{
				if let notes = userDatabase["notes"]{
					if let urlString = self.challengeURLString(){
						if let notesString:String = notes[urlString] as? String{
							if(!notesString.isEmpty){
								self.myLessonNotesString = notesString
								self.notesFooter.hasNotes = true
							}
						}
					}
				}
			}
		}
		
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
	
	func didPressNotesButton(sender: MyNotesFooterView) {
		let vc = NotesViewController()
		vc.lessonTarget = self.challengeURLString()
		vc.textView.text = myLessonNotesString
		self.navigationController?.pushViewController(vc, animated: true)
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
			vc.feedbackTargetType = "lessons"
			self.navigationController?.pushViewController(vc, animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Submit my own Lesson", style: .default , handler:{ (UIAlertAction)in
			let vc = CreateLessonViewController()
			self.navigationController?.present(vc, animated: true, completion:nil)
		}))
		alert.addAction(UIAlertAction(title: "Print", style: .default , handler:{ (UIAlertAction)in
			self.createPDF()
			self.sharePDFFile()
//			self.showPDFFile()
		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:nil))
		self.present(alert, animated: true) { }
	}
	
	
	
	func createPDF(){
		let fileName = "lesson.pdf"
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let pdfFileNameStep1 = path.appending("/")
		let pdfFileName = pdfFileNameStep1.appending(fileName)
		
		do {
			try FileManager.default.removeItem(atPath: pdfFileName)
		} catch let error as NSError {
			print(error.debugDescription)
		}
		
		let cfTitleText = titleLabel.text! as CFString
		let cfBodyText = bodyText.text! as CFString
		// Prepare the text using a Core Text Framesetter.
		
		// create a dictionary of attributes to be applied to the string
		let titleOptions:CFDictionary = [NSFontAttributeName:UIFont(name: SYSTEM_FONT, size: 30)!] as CFDictionary
		let bodyOptions:CFDictionary = [NSFontAttributeName:UIFont(name: SYSTEM_FONT, size: 20)!] as CFDictionary
		
		let bodyString = CFAttributedStringCreate(nil, cfBodyText, bodyOptions)!
		let titleString = CFAttributedStringCreate(nil, cfTitleText, titleOptions)!

		let framesetterBody = CTFramesetterCreateWithAttributedString(bodyString)
		let framesetterTitle = CTFramesetterCreateWithAttributedString(titleString)
		let bodyFrameRect = CGRect(x: 30, y: 0, width: 612-60, height: 792-60)
		let bodyFramePath = CGPath.init(rect: bodyFrameRect, transform: nil)
		let titleFrameRect = CGRect(x: 30, y: 0, width: 612-60, height: 792-60)
		let titleFramePath = CGPath.init(rect: titleFrameRect, transform: nil)
		// Get the frame that will do the rendering.
		let currentRange = CFRange(location: 0, length: 0)
		let bodyFrameRef = CTFramesetterCreateFrame(framesetterBody, currentRange, bodyFramePath, nil)
		let titleFrameRef = CTFramesetterCreateFrame(framesetterTitle, currentRange, titleFramePath, nil)

		// Create the PDF context using the default page size of 612 x 792.
		UIGraphicsBeginPDFContextToFile(pdfFileName, CGRect.zero, nil)
		// Mark the beginning of a new page.
		UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:612, height:792), nil)
		// Get the graphics context.
		let currentContext = UIGraphicsGetCurrentContext()
		currentContext!.textMatrix = CGAffineTransform.identity
		// Core Text draws from the bottom-left corner up, so flip
		// the current transform prior to drawing.
		currentContext!.scaleBy(x: 1.0, y: -1.0)
		currentContext!.translateBy(x: 0, y: -792)
		CTFrameDraw(titleFrameRef, currentContext!)
		currentContext!.translateBy(x: 0, y: -60)
//		 Draw the frame.
		CTFrameDraw(bodyFrameRef, currentContext!)
//		 Close the PDF context and write the contents out.
		UIGraphicsEndPDFContext();
	}
	
	func sharePDFFile(){
		let fileName = "lesson.pdf"
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let pdfFileNameStep1 = path.appending("/")
		let pdfFileName = pdfFileNameStep1.appending(fileName)
		
		let documento = NSData(contentsOfFile: pdfFileName)
		let objectsToShare = [documento];
		
//		let types:[UIActivityType] = [.print, .airDrop, .mail, .message, .openInIBooks, .addToReadingList]
		let controller:UIActivityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		controller.excludedActivityTypes = [.postToFacebook, .postToVimeo, .postToWeibo, .postToFlickr, .postToTwitter]
		
		// Exclude activities
//		NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
//		UIActivityTypePostToWeibo,
//		UIActivityTypeMessage, UIActivityTypeMail,
//		UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
//		UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
//		UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
//		UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
//		controller.excludedActivityTypes = excludedActivities;
		
		self.present(controller, animated: true, completion: nil)
	}
	
	
	func showPDFFile(){
		let fileName = "lesson.pdf"
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let pdfFileNameStep1 = path.appending("/")
		let pdfFileName = pdfFileNameStep1.appending(fileName)
	
		let webView = UIWebView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
		let url:URL = URL(fileURLWithPath: pdfFileName)
		let request:URLRequest = URLRequest(url: url)
		webView.scalesPageToFit = true
		webView.loadRequest(request)
		
		self.view.addSubview(webView)
	}

}


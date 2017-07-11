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
		alert.addAction(UIAlertAction(title: "Print", style: .default , handler:{ (UIAlertAction)in
			self.createPDF()
			self.sharePDFFile()
//			self.showPDFFile()
		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:{ (UIAlertAction)in
			
		}))
		self.present(alert, animated: true) { }
	}

	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	
	
	
	
	func createPDF(){
		let fileName = "quote.pdf"
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let pdfFileNameStep1 = path.appending("/")
		let pdfFileName = pdfFileNameStep1.appending(fileName)
		
		do {
			try FileManager.default.removeItem(atPath: pdfFileName)
		} catch let error as NSError {
			print(error.debugDescription)
		}
		
		let cfTitleText = "“" as CFString
		let cfBodyText = quoteBodyView.text! as CFString
		// Prepare the text using a Core Text Framesetter.
		
		// create a dictionary of attributes to be applied to the string
		let titleOptions:CFDictionary = [NSFontAttributeName:UIFont(name: SYSTEM_FONT, size: 100)!] as CFDictionary
		let bodyOptions:CFDictionary = [NSFontAttributeName:UIFont(name: SYSTEM_FONT, size: 45)!] as CFDictionary
		
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
		currentContext!.translateBy(x: 0, y: -80)
		//		 Draw the frame.
		CTFrameDraw(bodyFrameRef, currentContext!)
		//		 Close the PDF context and write the contents out.
		UIGraphicsEndPDFContext();
	}
	
	func sharePDFFile(){
		let fileName = "quote.pdf"
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
		let fileName = "quote.pdf"
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

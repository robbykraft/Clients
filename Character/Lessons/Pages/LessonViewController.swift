//
//  ViewController.swift
//  Lessons
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonViewController: UIViewController {
	
	var data:Lesson?{
		didSet{
			let title:String = (data?.title)!
			let body:String = (data?.body)!
			let author:String = (data?.author)!

			let imageFilename = (data?.image)!
			Cache.shared.imageFromStorageBucket(imageFilename) { (image, requiredDownload) in
				self.imageView.image = image
			}
			
			let attributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 21)!,
			                  NSKernAttributeName : CGFloat(4.0),
			                  NSForegroundColorAttributeName : Style.shared.darkGray];
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: title.uppercaseString)
			aText.addAttributes(attributes, range: NSMakeRange(0, aText.length))
			self.titleLabel.numberOfLines = 0
			self.titleLabel.attributedText = aText

			
			bodyText.font = UIFont(name: SYSTEM_FONT, size: 15)
			bodyText.text = body
			
			authorLabel.font = UIFont(name: SYSTEM_FONT, size: 15)
			authorLabel.text = author
		}
	}
	
	let imageView = UIImageView()
	let authorLabel = UILabel()
	let bodyText = UITextView()
	let titleLabel = UILabel()

	let authorHR1 = UIView()
	let authorHR2 = UIView()
	
	let scrollView = UIScrollView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let navPad:CGFloat = 0//self.navigationController!.navigationBar.frame.size.height
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		
		scrollView.frame = self.view.frame
		self.view = scrollView
		
		self.view.backgroundColor = UIColor.whiteColor()
		
		self.view.addSubview(imageView)
		self.view.addSubview(authorLabel)
		self.view.addSubview(bodyText)
		self.view.addSubview(titleLabel)
		self.view.addSubview(authorHR1)
		self.view.addSubview(authorHR2)
		
		imageView.contentMode = .ScaleAspectFill
		imageView.clipsToBounds = true
		titleLabel.textAlignment = .Center
		titleLabel.numberOfLines = 0
		authorLabel.numberOfLines = 0
		authorLabel.textAlignment = .Center
		authorLabel.textColor = Style.shared.lightBlue
		bodyText.scrollEnabled = false
		authorHR1.backgroundColor = UIColor.blackColor()
		authorHR2.backgroundColor = UIColor.blackColor()
		
		// FRAME SETTING
		// IMAGE VIEW
		let imgHeight:CGFloat = self.view.frame.size.width * 175.0/300.0
		imageView.frame = CGRectMake(0, navPad, self.view.frame.size.width, imgHeight)
		
		// TITLE LABEL
		titleLabel.frame = CGRectMake(sidePad, navPad + imgHeight + 20, self.view.frame.size.width - sidePad*2, self.view.frame.size.height)
		titleLabel.sizeToFit()
		let titleHeight = titleLabel.frame.size.height
		titleLabel.frame = CGRectMake(sidePad, navPad + imgHeight + 20, self.view.frame.size.width - sidePad*2, titleHeight)
		
		// AUTHOR LABEL
		authorLabel.frame = CGRectMake(sidePad, titleLabel.frame.origin.y + titleHeight + 20, self.view.frame.size.width - sidePad*2, self.view.frame.size.height)
		authorLabel.sizeToFit()
		let authorHeight = authorLabel.frame.size.height
		authorLabel.frame = CGRectMake(sidePad, titleLabel.frame.origin.y + titleHeight + 20, self.view.frame.size.width - sidePad*2, authorHeight)
		
		// LESSON BODY
		bodyText.frame = CGRectMake(sidePad, authorLabel.frame.origin.y + authorHeight + 20, self.view.frame.size.width - sidePad*2, self.view.frame.size.height)
		bodyText.sizeToFit()
		let bodyHeight = bodyText.frame.size.height
		
		authorHR1.frame = CGRectMake(sidePad, authorLabel.frame.origin.y - 10, self.view.frame.size.width - sidePad*2, 1)
		authorHR2.frame = CGRectMake(sidePad, authorLabel.frame.origin.y + authorHeight + 10, self.view.frame.size.width - sidePad*2, 1)
		
		scrollView.contentSize = CGSizeMake(self.view.frame.size.width, bodyText.frame.origin.y + bodyHeight + 20)
	}
}


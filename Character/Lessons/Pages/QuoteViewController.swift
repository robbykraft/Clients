//
//  QuoteViewController.swift
//  Lessons
//
//  Created by Robby on 8/15/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {

	var data: Lesson?{
		didSet{
			quoteBodyView.text = data?.quote
			quoteAuthorLabel.text = data?.quoteAuthor
		}
	}
	
	let quoteMarkImageView = UIImageView()
	
	let quoteBodyView = UITextView()
	let quoteAuthorLabel = UILabel()
	
	let scrollView = UIScrollView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		scrollView.frame = self.view.frame
		self.view = scrollView
		self.view.backgroundColor = UIColor.whiteColor()
		
		quoteMarkImageView.image = UIImage.init(named: "quote-image")

		quoteBodyView.scrollEnabled = false;
		quoteBodyView.font = UIFont(name: SYSTEM_FONT, size: 25)
		quoteAuthorLabel.font = UIFont(name: SYSTEM_FONT_I, size: 25)
		quoteAuthorLabel.textAlignment = .Center
		quoteAuthorLabel.numberOfLines = 0
		quoteAuthorLabel.textColor = Style.shared.lightBlue
		
		self.view.addSubview(quoteMarkImageView)
		self.view.addSubview(quoteBodyView)
		self.view.addSubview(quoteAuthorLabel)
		
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		
		// FRAME SETTING
		// QUOTE MARK
		quoteMarkImageView.frame = CGRectMake(0, 0, 40, 40)
		quoteMarkImageView.center = CGPointMake(self.view.frame.size.width*0.5, 70)
		let imgHeight = quoteMarkImageView.frame.origin.y + quoteMarkImageView.frame.size.height

		// QUOTE BODY
		quoteBodyView.frame = CGRectMake(sidePad, imgHeight + 20,
		                                 self.view.frame.size.width - sidePad*2, self.view.frame.size.height)
		quoteBodyView.sizeToFit()
		let quoteBodyHeight = quoteBodyView.frame.size.height
		quoteBodyView.frame = CGRectMake(sidePad, imgHeight + 20,
		                                 self.view.frame.size.width - sidePad*2, quoteBodyHeight)
		
		// AUTHOR LABEL
		quoteAuthorLabel.frame = CGRectMake(sidePad, quoteBodyView.frame.origin.y + quoteBodyHeight + 20, self.view.frame.size.width - sidePad*2, self.view.frame.size.height)
		quoteAuthorLabel.sizeToFit()
		let authorHeight = quoteAuthorLabel.frame.size.height
		quoteAuthorLabel.frame = CGRectMake(sidePad, quoteBodyView.frame.origin.y + quoteBodyHeight + 20, self.view.frame.size.width - sidePad*2, authorHeight)
		
		scrollView.contentSize = CGSizeMake(self.view.frame.size.width, quoteAuthorLabel.frame.origin.y + authorHeight + 20)
    }
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//
//  CreateLessonViewController.swift
//  Character
//
//  Created by Robby on 3/28/16.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

class CreateQuoteViewController: UIViewController, UITextViewDelegate {
	
	let scrollView = UIScrollView()
	
	let quoteMarkImageView = UIImageView()
	let quoteBodyView = UITextView()
	let quoteAuthorField = UITextField()

	let submitButton = UIButton()
	
	let fakeNavBar = UIView()
	let navTitle = UILabel()
	let closeButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let navPad:CGFloat = 44 + 20//self.navigationController!.navigationBar.frame.size.height
		
		let sidePad:CGFloat = self.view.frame.size.width * 0.1
		
		scrollView.frame = self.view.frame
		self.view.addSubview( scrollView )

		// NAV BAR
		self.view.addSubview(fakeNavBar)
		fakeNavBar.addSubview(navTitle)
		fakeNavBar.addSubview(closeButton)
		scrollView.backgroundColor = UIColor.white
		fakeNavBar.backgroundColor = Style.shared.darkGray
		navTitle.textAlignment = .center
		navTitle.text = "SUBMIT A QUOTE"
		navTitle.textColor = UIColor.white
		closeButton.setTitle("×", for: .normal)
		closeButton.setTitleColor(UIColor.white, for: .normal)
		navTitle.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		closeButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)


		quoteMarkImageView.image = UIImage.init(named: "quote-image")
		
//		quoteBodyView.isScrollEnabled = false;
		quoteBodyView.isEditable = true
		quoteBodyView.delegate = self
		quoteBodyView.returnKeyType = .done
		quoteBodyView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		quoteBodyView.backgroundColor = UIColor.white
		quoteAuthorField.font = UIFont(name: SYSTEM_FONT_I, size: Style.shared.P24)
		quoteAuthorField.textAlignment = .center
		quoteAuthorField.textColor = Style.shared.lightBlue
		quoteAuthorField.backgroundColor = UIColor.white
		
		quoteAuthorField.placeholder = "Quote Author"
		
		scrollView.addSubview(quoteMarkImageView)
		scrollView.addSubview(quoteBodyView)
		scrollView.addSubview(quoteAuthorField)

		closeButton.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)

		scrollView.backgroundColor = Style.shared.whiteSmoke

		submitButton.backgroundColor = Style.shared.lightBlue
		submitButton.setTitle("SUBMIT", for: UIControlState())
		submitButton.setTitleColor(UIColor.white, for: UIControlState())
		submitButton.addTarget(self, action: #selector(submitButtonHandler), for: .touchUpInside)
		
		scrollView.addSubview(submitButton)

		// FRAME SETTING
		// IMAGE VIEW
		fakeNavBar.frame = CGRect(x: 0.0, y: 0.0, width: scrollView.frame.size.width, height: navPad)
		navTitle.frame = CGRect(x: 0.0, y: 20, width: scrollView.frame.size.width, height: navPad-20)
		closeButton.frame = CGRect(x: self.view.frame.size.width-navPad+20-10, y: 20.0, width: navPad-20, height: navPad-20)
		
		// FRAME SETTING
		// QUOTE MARK
		quoteMarkImageView.frame = CGRect(x: 0, y: navPad, width: 40, height: 40)
		quoteMarkImageView.center = CGPoint(x: self.view.frame.size.width*0.5, y: navPad+40)
		let imgHeight = quoteMarkImageView.frame.origin.y + quoteMarkImageView.frame.size.height
		
		// QUOTE BODY
		quoteBodyView.frame = CGRect(x: sidePad, y: imgHeight + 20,
		                             width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
//		quoteBodyView.sizeToFit()
		let quoteBodyHeight = self.view.frame.size.height * 0.5;//quoteBodyView.frame.size.height
		quoteBodyView.frame = CGRect(x: sidePad, y: imgHeight + 20,
		                             width: self.view.frame.size.width - sidePad*2, height: quoteBodyHeight)
		
		// AUTHOR LABEL
		quoteAuthorField.frame = CGRect(x: sidePad, y: quoteBodyView.frame.origin.y + quoteBodyHeight + 20, width: self.view.frame.size.width - sidePad*2, height: self.view.frame.size.height)
//		quoteAuthorField.sizeToFit()
		let authorHeight:CGFloat = 44.0;//quoteAuthorField.frame.size.height
		quoteAuthorField.frame = CGRect(x: sidePad, y: quoteBodyView.frame.origin.y + quoteBodyHeight + 20, width: self.view.frame.size.width - sidePad*2, height: authorHeight)
		
		submitButton.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: 44)
		submitButton.center = CGPoint(x: scrollView.center.x, y: quoteAuthorField.frame.origin.y + authorHeight + 20 + 44)
		
		scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: submitButton.center.y + 60 )
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		textView.becomeFirstResponder()
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n"){
			textView.resignFirstResponder()
			return false
		}
		return true
	}
	
	func closeButtonPress(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func submitButtonHandler(){

		var userString:String = ""
		if let uid = Fire.shared.myUID {
			userString = uid
		}
		let quoteObject:[String:Any] = [
			"body": quoteBodyView.text ?? "",
			"author": quoteAuthorField.text ?? "",
			"createdAt": Date.init().timeIntervalSince1970,
			"user": userString
		]

		Fire.shared.newUniqueObjectAtPath("quote", object: quoteObject as AnyObject) {
			let alertController = UIAlertController.init(title: "Quote Submitted", message: "Thank you for contributing!", preferredStyle: .alert)
			let okayButton = UIAlertAction.init(title: "Okay", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			})
			alertController.addAction(okayButton)
			self.present(alertController, animated: true, completion: nil)
		}
		
	}
	
}

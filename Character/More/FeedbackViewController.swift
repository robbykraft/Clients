//
//  FeedbackViewController.swift
//  Character
//
//  Created by Robby on 8/27/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {

	let textView = UITextView()
	let submitButton = UIButton()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "APP FEEDBACK"
		
		submitButton.backgroundColor = Style.shared.lightBlue
		submitButton.setTitle("SUBMIT", forState: .Normal)
		submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		submitButton.addTarget(self, action: #selector(submitButtonHandler), forControlEvents: .TouchUpInside)
		
		textView.delegate = self
		textView.backgroundColor = UIColor.whiteColor()
		textView.returnKeyType = .Done
		textView.font = UIFont(name: SYSTEM_FONT, size: 18)

		self.view.addSubview(textView)
		self.view.addSubview(submitButton)
        // Do any additional setup after loading the view.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
	
		let pad:CGFloat = 30
		textView.frame = CGRectMake(pad, pad, self.view.frame.size.width - pad*2, self.view.frame.size.height - pad*2 - 60 - navBarHeight - tabBarHeight - statusBarHeight())
		submitButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 44)
		submitButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - pad - 22 - navBarHeight - tabBarHeight - statusBarHeight())

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		textView.becomeFirstResponder()
	}
	
	func submitButtonHandler(){
		let feedbackObject:[String:AnyObject] = [
			"text": textView.text,
			"createdAt": NSDate.init().timeIntervalSince1970
		]

		Fire.shared.newUniqueObjectAtPath("feedback", object: feedbackObject) {
			let alertController = UIAlertController.init(title: "Feedback Sent", message: "Thank you for taking time to help!", preferredStyle: .Alert)
			let okayButton = UIAlertAction.init(title: "Okay", style: .Default, handler: { (action) in
				self.navigationController?.popViewControllerAnimated(true)
			})
			alertController.addAction(okayButton)
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	}
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n"){
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}

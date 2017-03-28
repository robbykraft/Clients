//
//  FeedbackViewController.swift
//  Character
//
//  Created by Robby on 8/27/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITextViewDelegate {

	let textView = UITextView()
//	let submitButton = UIButton()
	
	var lessonTarget:String?

	var updateTimer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "NOTES"
		
//		submitButton.backgroundColor = Style.shared.lightBlue
//		submitButton.setTitle("SUBMIT", for: UIControlState())
//		submitButton.setTitleColor(UIColor.white, for: UIControlState())
//		submitButton.addTarget(self, action: #selector(submitButtonHandler), for: .touchUpInside)
		
		textView.delegate = self
		textView.backgroundColor = UIColor.white
		textView.returnKeyType = .done
		textView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		self.view.addSubview(textView)
//		self.view.addSubview(submitButton)
        // Do any additional setup after loading the view.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
	
		let pad:CGFloat = 30
		textView.frame = CGRect(x: pad, y: pad, width: self.view.frame.size.width - pad*2, height: self.view.frame.size.height - pad*2 - navBarHeight - tabBarHeight - statusBarHeight())
//		submitButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44)
//		submitButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height - pad - 22 - navBarHeight - tabBarHeight - statusBarHeight())

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		textView.becomeFirstResponder()
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		updateWithDelay()
	}
	
	func updateWithDelay() {
		// hanging text fields
		if let lesson = lessonTarget{
			let path = "notes/" + lesson + "/"
			Fire.shared.updateUserWithKeyAndValue(path, value:self.textView.text  as AnyObject, completionHandler: nil)
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n"){
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}

//
//  CreateProjectViewController.swift
//  Voila
//
//  Created by Robby on 7/14/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class EditProjectViewController: UIViewController, UITextFieldDelegate{
	
	// for the ios keyboard covers textfield thing
	let scrollView:UIScrollView = UIScrollView()
	var activeField: UITextField?
	var keyboardSize: CGSize?
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let lockboxField: UITextField = UITextField()
	let clientField: UITextField = UITextField()
	let realtorField: UITextField = UITextField()
	let deleteButton: UIButton = UIButton()
	
	var updateTimer:Timer?  // live updates to profile entries, prevents updating too frequently
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.scrollView.frame = self.view.bounds
		self.scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
		self.scrollView.backgroundColor = Style.shared.whiteSmoke
		self.scrollView.isScrollEnabled = false
		self.view.addSubview(scrollView)

		self.title = "DETAILS"
		
		// buttons
		deleteButton.setTitle("Delete", for: .normal)
		deleteButton.addTarget(self, action: #selector(deleteProject), for: UIControl.Event.touchUpInside)
		
		// ui custom
		nameField.delegate = self
		emailField.delegate = self
		lockboxField.delegate = self
		clientField.delegate = self
		realtorField.delegate = self
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.backgroundColor = UIColor.white
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = .white
		emailField.backgroundColor = .white
		lockboxField.backgroundColor = .white
		clientField.backgroundColor = .white
		realtorField.backgroundColor = .white
		deleteButton.backgroundColor = Style.shared.highlight
		nameField.placeholder = "Name"
		emailField.placeholder = "Email"
		lockboxField.placeholder = "Lockbox Info"
		clientField.placeholder = "Client Name"
		realtorField.placeholder = "Realtor Info"
		
		// text field padding
		let paddingName = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingEmail = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingLockbox = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingClient = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingRealtor = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		nameField.leftView = paddingName
		emailField.leftView = paddingEmail
		lockboxField.leftView = paddingLockbox
		clientField.leftView = paddingClient
		realtorField.leftView = paddingRealtor
		nameField.leftViewMode = .always
		emailField.leftViewMode = .always
		lockboxField.leftViewMode = .always
		clientField.leftViewMode = .always
		realtorField.leftViewMode = .always
		clientField.autocapitalizationType = .words
		realtorField.autocapitalizationType = .words
		nameField.autocapitalizationType = .words

		emailField.keyboardType = .emailAddress
		
		self.scrollView.addSubview(profileImageView)
		self.scrollView.addSubview(profileImageButton)
		self.scrollView.addSubview(nameField)
		self.scrollView.addSubview(emailField)
		self.scrollView.addSubview(lockboxField)
		self.scrollView.addSubview(clientField)
		self.scrollView.addSubview(realtorField)
		self.scrollView.addSubview(deleteButton)
		
		self.registerForKeyboardNotifications()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// frames
		let imgSize:CGFloat = self.view.bounds.size.width * 0.4
		let imgArea:CGFloat = self.view.bounds.size.width * 0.5
		profileImageView.frame = CGRect(x: 0, y: 0, width: imgSize, height: imgSize)
		profileImageView.center = CGPoint(x: self.view.center.x, y: imgArea*0.5)
		profileImageView.layer.cornerRadius = imgSize*0.5
		profileImageButton.frame = profileImageView.frame
		nameField.frame = CGRect(x: 0, y: imgArea + 10, width: self.view.bounds.size.width, height: 44)
		emailField.frame = CGRect(x: 0, y: imgArea + 10*2 + 44*1, width: self.view.bounds.size.width, height: 44)
		clientField.frame = CGRect(x: 0, y: imgArea + 10*3 + 44*2, width: self.view.bounds.size.width, height: 44)
		lockboxField.frame = CGRect(x: 0, y: imgArea + 10*4 + 44*3, width: self.view.bounds.size.width, height: 44)
		realtorField.frame = CGRect(x: 0, y: imgArea + 10*5 + 44*4, width: self.view.bounds.size.width, height: 44)
		deleteButton.frame = CGRect(x: 0, y: imgArea + 10*6 + 44*5, width: self.view.bounds.size.width, height: 44)
		
		// populate screen
		self.populateData()
		
		NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: nil)
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
		self.deregisterFromKeyboardNotifications()
	}
	
	@objc func deleteProject(){
		if let thisProject = Voila.shared.project{
			Fire.shared.database.child("projects").child(thisProject.key).removeValue { error,_  in
				if let masterNav = self.navigationController as? MasterNavigationController{
					masterNav.projectsVC.reloadData({
						Voila.shared.project = nil
						self.navigationController?.popToRootViewController(animated: true)
					})
				}
			}
		}
	}
	
	func populateData(){
		if let project = Voila.shared.project{
			if let email = project.email{
				self.emailField.text = email
			}
			if let lockbox = project.lockbox{
				self.lockboxField.text = lockbox
			}
			if let clientName = project.clientName{
				self.clientField.text = clientName
			}
			if let realtorName = project.realtorName{
				self.realtorField.text = realtorName
			}
			self.nameField.text = project.name
		}
		profileImageView.image = UIImage(named: "house")
//		if let profileImage = userData["image"] as? String{
//			Fire.shared.imageFromStorageBucket(profileImage, completionHandler: { (image, didRequireDownload) in
//				self.profileImageView.image = image
//			})
//		} else{
//			// blank profile image
//			profileImageView.image = nil
//		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	@objc func textFieldDidChange(_ notif: Notification) {
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	@objc func updateWithDelay() {
		// TODO: list all UITextFields here
		if let project = Voila.shared.project{
			if let nameText = nameField.text{
				project.name = nameText
			}
			if let emailText = emailField.text{
				project.email = emailText
			}
			if let clientNameText = clientField.text{
				project.clientName = clientNameText
			}
			if let realtorNameText = realtorField.text{
				project.realtorName = realtorNameText
			}
			project.synchronize(completionHandler: nil)
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		activeField = nil
		// TODO: list all UITextFields here
//		if(textField.isEqual(nameField)){
//			Fire.shared.updateCurrentUserWith(key: "displayName", object: textField.text!, completionHandler: nil)
//		}
//		if(textField.isEqual(detailField)){
//			Fire.shared.updateCurrentUserWith(key: "detail", object: textField.text!, completionHandler: nil)
//		}
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func registerForKeyboardNotifications(){
		//Adding notifies on keyboard appearing
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func deregisterFromKeyboardNotifications(){
		//Removing notifies on keyboard appearing
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWasShown(notification: NSNotification){
		//Need to calculate keyboard exact size due to Apple suggestions
		self.scrollView.isScrollEnabled = true
		if self.keyboardSize == nil{
//			var info = notification.userInfo!
//			let keySize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
			self.keyboardSize = CGSize(width: self.view.bounds.size.width, height: 270)//keySize
		}
		if let activeField = self.activeField {
			let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
			let statusHeight:CGFloat = statusBarHeight()
			let header = navBarHeight + statusHeight
			var newSize = self.view.bounds.size
			newSize.height += (self.keyboardSize?.height)! - header
			self.scrollView.contentSize = newSize
			let fieldFromBottom = (self.scrollView.bounds.size.height-activeField.frame.origin.y-120)
			let scrollToY = newSize.height - 1 - fieldFromBottom
			self.scrollView.scrollRectToVisible(CGRect.init(x: 0, y: scrollToY, width: 1, height: 1), animated: true)
		}
	}
	
	@objc func keyboardWillBeHidden(notification: NSNotification){
		self.scrollView.contentSize = self.view.bounds.size
		self.scrollView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
		self.view.endEditing(true)
		self.scrollView.isScrollEnabled = false
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField){
		activeField = textField
	}
	

}

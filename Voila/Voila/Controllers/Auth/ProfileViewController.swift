//
//  ProfileViewController.swift
//  Voila
//
//  Created by Robby on 7/5/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import Firebase

func dateStringForUnixTime(_ unixTime:Double) -> String{
	let date:Date = Date(timeIntervalSince1970: unixTime)
	let dateFormatter:DateFormatter = DateFormatter.init()
	dateFormatter.dateStyle = .long
	return dateFormatter.string(from: date)
}

func timeStringForUnixTime(_ unixTime:Double) -> String {
	let date:Date = Date(timeIntervalSince1970: unixTime)
	let dateFormatter:DateFormatter = DateFormatter.init()
	dateFormatter.timeStyle = .medium
	return dateFormatter.string(from: date)
}


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let creationDateField: UITextField = UITextField()
	let detailField: UITextField = UITextField()
	let signoutButton: UIButton = UIButton()
	
	var updateTimer:Timer?  // live updates to profile entries, prevents updating too frequently
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let lightBlue = UIColor(red:0.33, green:0.65, blue:0.95, alpha:1.00)
		let gray = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.00)
		let whiteSmoke = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)

		self.view.backgroundColor = whiteSmoke
		
		self.title = "MY PROFILE"
		
		// buttons
		signoutButton.setTitle("Sign Out", for: .normal)
		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), for: .touchUpInside)
		signoutButton.addTarget(self, action: #selector(logOut), for: UIControl.Event.touchUpInside)
		
		// ui custom
		nameField.delegate = self
		emailField.delegate = self
		creationDateField.delegate = self
		detailField.delegate = self
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.backgroundColor = UIColor.white
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = UIColor.white
		emailField.backgroundColor = UIColor.white
		creationDateField.backgroundColor = UIColor.white
		detailField.backgroundColor = UIColor.white
		signoutButton.backgroundColor = lightBlue
		nameField.placeholder = "Name"
		emailField.placeholder = "Email Address"
		creationDateField.placeholder = "Creation Date"
		detailField.placeholder = "Detail Text"
		
		emailField.isEnabled = false
		creationDateField.isEnabled = false
		emailField.textColor = gray
		creationDateField.textColor = gray
		
		// text field padding
		let paddingName = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingEmail = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingCreationDate = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingDetail = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		nameField.leftView = paddingName
		emailField.leftView = paddingEmail
		creationDateField.leftView = paddingCreationDate
		detailField.leftView = paddingDetail
		nameField.leftViewMode = .always
		emailField.leftViewMode = .always
		creationDateField.leftViewMode = .always
		detailField.leftViewMode = .always
		
		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(creationDateField)
		self.view.addSubview(detailField)
		self.view.addSubview(signoutButton)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let statusHeight:CGFloat = statusBarHeight()

		let header = navBarHeight + statusHeight
		
		// frames
		let imgSize:CGFloat = self.view.bounds.size.width * 0.4
		let imgArea:CGFloat = self.view.bounds.size.width * 0.5
		profileImageView.frame = CGRect(x: 0, y: 0, width: imgSize, height: imgSize)
		profileImageView.center = CGPoint(x: self.view.center.x, y: header + imgArea*0.5)
		profileImageView.layer.cornerRadius = imgSize*0.5
		profileImageButton.frame = profileImageView.frame
		nameField.frame = CGRect(x: 0, y: header + imgArea + 10, width: self.view.bounds.size.width, height: 44)
		emailField.frame = CGRect(x: 0, y: header + imgArea + 10*2 + 44*1, width: self.view.bounds.size.width, height: 44)
		creationDateField.frame = CGRect(x: 0, y: header + imgArea + 10*3 + 44*2, width: self.view.bounds.size.width, height: 44)
		detailField.frame = CGRect(x: 0, y: header + imgArea + 10*4 + 44*3, width: self.view.bounds.size.width, height: 44)
		signoutButton.frame = CGRect(x: 0, y: header + imgArea + 10*5 + 44*4, width: self.view.bounds.size.width, height: 44)
		
		// populate screen
		Fire.shared.getCurrentUser { (uid, userData) in
			self.populateUserData(uid, userData: userData)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: nil)
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
	}
	
	func populateUserData(_ uid:String, userData:[String:Any]){
		if let profileImage = userData["image"] as? String{
			Fire.shared.imageFromStorageBucket(profileImage, completionHandler: { (image, didRequireDownload) in
				self.profileImageView.image = image
			})
		} else{
			// blank profile image
			profileImageView.image = nil
		}
		
		let dateString = dateStringForUnixTime(userData["createdAt"] as! Double)
		let timeString = timeStringForUnixTime(userData["createdAt"] as! Double)
		
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
		creationDateField.text = dateString + " " + timeString
		detailField.text = userData["detail"] as? String
	}
	
	@objc func logOut(){
		do{
			try Auth.auth().signOut()
			self.navigationController?.dismiss(animated: true, completion: nil)
		}catch{
			
		}
	}
	
	@objc func profilePictureButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "Change Profile Image", message: nil, preferredStyle: .actionSheet)
		let action1 = UIAlertAction.init(title: "Camera", style: .default) { (action) in
			self.openImagePicker(.camera)
		}
		let action2 = UIAlertAction.init(title: "Photos", style: .default) { (action) in
			self.openImagePicker(.photoLibrary)
		}
		let action3 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.present(alert, animated: true, completion: nil)
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
		if let nameText = nameField.text{
			Fire.shared.updateCurrentUserWith(key:"displayName", object: nameText, completionHandler: nil)
		}
		if let detailText = detailField.text{
			Fire.shared.updateCurrentUserWith(key: "detail", object: detailText, completionHandler: nil)
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// TODO: list all UITextFields here
		if(textField.isEqual(nameField)){
			Fire.shared.updateCurrentUserWith(key: "displayName", object: textField.text!, completionHandler: nil)
		}
		if(textField.isEqual(detailField)){
			Fire.shared.updateCurrentUserWith(key: "detail", object: textField.text!, completionHandler: nil)
		}
	}
	
	func openImagePicker(_ sourceType:UIImagePickerController.SourceType) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = sourceType
		self.navigationController?.present(imagePicker, animated: true, completion: nil)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		let image = info[.originalImage] as! UIImage
		let imageData = image.jpegData(compressionQuality: 0.5)
		if let data = imageData{
			Fire.shared.uploadFileAndMakeRecord(data, fileType: .JPG, description: nil, completionHandler: { (metadata) in
				Fire.shared.updateCurrentUserWith(key: "image", object: metadata.filename, completionHandler: { (success) in
					if success{
						self.profileImageView.image = image
					}
				})
			})
		}
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
}

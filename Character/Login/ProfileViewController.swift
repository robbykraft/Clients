//
//  ProfileViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let detail1Button: UIButton = UIButton()
	let detailPillarButton: UIButton = UIButton()
	let signoutButton: UIButton = UIButton()
	
	var updateTimer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "MY PROFILE"

		// buttons
		signoutButton.setTitle("Sign Out", for: UIControlState())
		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), for: .touchUpInside)
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), for: UIControlEvents.touchUpInside)
		detailPillarButton.addTarget(self, action: #selector(pillarOrderPressed), for: UIControlEvents.touchUpInside)
		signoutButton.addTarget(self, action: #selector(logOut), for: UIControlEvents.touchUpInside)

		// ui custom
		nameField.delegate = self
		emailField.delegate = self
//		detail2Field.delegate = self
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.backgroundColor = UIColor.white
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = UIColor.white
		emailField.backgroundColor = UIColor.white
		detail1Button.backgroundColor = UIColor.white
		detail1Button.setTitleColor(UIColor.black, for: UIControlState())
		detail1Button.titleLabel?.textAlignment = .center
		detailPillarButton.backgroundColor = UIColor.white
		detailPillarButton.setTitleColor(UIColor.black, for: UIControlState())
		detailPillarButton.titleLabel?.textAlignment = .center
//		detail2Field.backgroundColor = UIColor.whiteColor()
		signoutButton.backgroundColor = Style.shared.lightBlue
		nameField.placeholder = "Name"
		emailField.placeholder = "Email Address"
		detailPillarButton.setTitle("Pillar Order", for: UIControlState())
//		detail2Field.placeholder = "Detail Text"
		
		emailField.isEnabled = false
		
		// text field padding
		let paddingName = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 40))
		let paddingEmail = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 40))
		nameField.leftView = paddingName
		emailField.leftView = paddingEmail
		nameField.leftViewMode = .always
		emailField.leftViewMode = .always

		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(detail1Button)
		self.view.addSubview(detailPillarButton)
		self.view.addSubview(signoutButton)
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
		detail1Button.frame = CGRect(x: 0, y: imgArea + 10*3 + 44*2, width: self.view.bounds.size.width, height: 44)
		detailPillarButton.frame = CGRect(x: 0, y: imgArea + 10*4 + 44*3, width: self.view.bounds.size.width, height: 44)
		signoutButton.frame = CGRect(x: 0, y: imgArea + 10*5 + 44*4, width: self.view.bounds.size.width, height: 44)

		
		// populate screen
		Fire.shared.getUser { (uid, userData) in
			if(uid != nil && userData != nil){
				self.populateUserData(uid!, userData: userData!)
			}
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: nil)

	}

	
	func populateUserData(_ uid:String, userData:[String:AnyObject]){
		if(userData["image"] != nil){
			profileImageView.profileImageFromUID(uid)
//			profileImageView.imageFromUrl(userData["image"] as! String)
		}
		else{
			// blank profile image
			profileImageView.image = UIImage(named: "person")?.imageWithTint(Style.shared.lightBlue)
		}
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
//		detail2Field.text = userData["detail2"] as? String

		var gradeLevels:[Int]? = userData["grade"] as? [Int]
		if(gradeLevels == nil){
			gradeLevels = [0,1,2,3]
		}
		if(gradeLevels!.contains(0) && gradeLevels!.contains(1) && gradeLevels!.contains(2) && gradeLevels!.contains(3)){
			detail1Button.setTitle("All Grades", for: UIControlState())
		}
		else if(gradeLevels!.contains(0)){
			detail1Button.setTitle(Character.shared.gradeNames[0], for: UIControlState())
		}
		else if(gradeLevels!.contains(1)){
			detail1Button.setTitle(Character.shared.gradeNames[1], for: UIControlState())
		}
		else if(gradeLevels!.contains(2)){
			detail1Button.setTitle(Character.shared.gradeNames[2], for: UIControlState())
		}
		else if(gradeLevels!.contains(3)){
			detail1Button.setTitle(Character.shared.gradeNames[3], for: UIControlState())
		}
	}
	
	func pillarOrderPressed(_ sender:UIButton){
		self.navigationController?.pushViewController(PillarOrderTableViewController(), animated: true)
	}
	
	func logOut(){
		do{
			try FIRAuth.auth()?.signOut()
			self.navigationController?.dismiss(animated: true, completion: nil)
		}catch{
			
		}
	}
	
	func detail1ButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[0], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0] as AnyObject, completionHandler: nil)
			let master:MasterController = self.tabBarController as! MasterController
			Character.shared.myGradeLevel = [0]
			master.reloadLessons()
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[1], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [1] as AnyObject, completionHandler: nil)
			let master:MasterController = self.tabBarController as! MasterController
			Character.shared.myGradeLevel = [1]
			master.reloadLessons()
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[2], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [2] as AnyObject, completionHandler: nil)
			let master:MasterController = self.tabBarController as! MasterController
			Character.shared.myGradeLevel = [2]
			master.reloadLessons()
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .default) { (action) in
			self.detail1Button.setTitle(Character.shared.gradeNames[3], for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [3] as AnyObject, completionHandler: nil)
			let master:MasterController = self.tabBarController as! MasterController
			Character.shared.myGradeLevel = [3]
			master.reloadLessons()
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .default) { (action) in
			self.detail1Button.setTitle("All Grades", for: UIControlState())
			Fire.shared.updateUserWithKeyAndValue("grade", value: [0,1,2,3] as AnyObject, completionHandler: nil)
			let master:MasterController = self.tabBarController as! MasterController
			Character.shared.myGradeLevel = [0,1,2,3]
			master.reloadLessons()
		}
		
		let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		alert.addAction(action4)
		alert.addAction(action5)
		alert.addAction(cancel)

		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.present(alert, animated: true, completion: nil)


	}
	
	func profilePictureButtonHandler(_ sender:UIButton){
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
	func textFieldDidChange(_ notif: Notification) {
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	func updateWithDelay() {
		// hanging text fields
		Fire.shared.updateUserWithKeyAndValue("displayName", value: nameField.text! as AnyObject, completionHandler: nil)

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
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if(textField.isEqual(nameField)){
			Fire.shared.updateUserWithKeyAndValue("displayName", value: textField.text! as AnyObject, completionHandler: nil)
		}
//		if(textField.isEqual(detail2Field)){
//			Fire.shared.updateUserWithKeyAndValue("detail2", value: textField.text!, completionHandler: nil)
//		}
	}
//	override func textFieldDidBeginEditing(textField: UITextField) {
//		
//	}
	
	
	func openImagePicker(_ sourceType:UIImagePickerControllerSourceType) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = sourceType
		self.navigationController?.present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let data = UIImageJPEGRepresentation(image, 0.5)
		if(data != nil){
			Fire.shared.uploadFileAndMakeRecord(data!, folder:nil, fileType: .image_JPG, description: nil, completionHandler: { (downloadURL) in
				if(downloadURL != nil){
					Fire.shared.updateUserWithKeyAndValue("image", value: downloadURL!.absoluteString as AnyObject, completionHandler: { (success) in
						if(success){
							Cache.shared.profileImage[Fire.shared.myUID!] = image
							self.profileImageView.image = image
						}
						else{
							
						}
					})
				}
			})
		}
		if(data == nil){
			print("image picker data is nil")
		}
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
}

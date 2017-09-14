//
//  CreateProjectViewController.swift
//  Voila
//
//  Created by Robby on 7/14/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class EditProjectViewController: UIViewController, UITextFieldDelegate{
	
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let lockboxField: UITextField = UITextField()
//	let creationDateField: UITextField = UITextField()
//	let detailField: UITextField = UITextField()
	let deleteButton: UIButton = UIButton()
	
	var updateTimer:Timer?  // live updates to profile entries, prevents updating too frequently
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		
		self.title = "DETAILS"
		
		// buttons
		deleteButton.setTitle("Delete", for: UIControlState())
//		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), for: .touchUpInside)
		deleteButton.addTarget(self, action: #selector(deleteProject), for: UIControlEvents.touchUpInside)
		
		// ui custom
		nameField.delegate = self
		emailField.delegate = self
		lockboxField.delegate = self
//		creationDateField.delegate = self
//		detailField.delegate = self
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.backgroundColor = UIColor.white
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = UIColor.white
		emailField.backgroundColor = UIColor.white
		lockboxField.backgroundColor = UIColor.white
//		creationDateField.backgroundColor = UIColor.white
//		detailField.backgroundColor = UIColor.white
		deleteButton.backgroundColor = Style.shared.red
		nameField.placeholder = "Name"
		emailField.placeholder = "Email"
		lockboxField.placeholder = "Lockbox Info"
//		creationDateField.placeholder = "Creation Date"
//		detailField.placeholder = "Detail Text"
		
//		lockboxField.isEnabled = false
//		creationDateField.isEnabled = false
//		lockboxField.textColor = gray
//		creationDateField.textColor = gray
		
		// text field padding
		let paddingName = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingEmail = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		let paddingLockbox = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
		nameField.leftView = paddingName
		emailField.leftView = paddingEmail
		lockboxField.leftView = paddingLockbox
//		creationDateField.leftView = paddingCreationDate
//		detailField.leftView = paddingDetail
		nameField.leftViewMode = .always
		emailField.leftViewMode = .always
		lockboxField.leftViewMode = .always
//		creationDateField.leftViewMode = .always
//		detailField.leftViewMode = .always
		
		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(lockboxField)
//		self.view.addSubview(detailField)
		self.view.addSubview(deleteButton)
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
		lockboxField.frame = CGRect(x: 0, y: header + imgArea + 10*3 + 44*2, width: self.view.bounds.size.width, height: 44)
//		creationDateField.frame = CGRect(x: 0, y: header + imgArea + 10*3 + 44*2, width: self.view.bounds.size.width, height: 44)
//		detailField.frame = CGRect(x: 0, y: header + imgArea + 10*4 + 44*3, width: self.view.bounds.size.width, height: 44)
		deleteButton.frame = CGRect(x: 0, y: header + imgArea + 10*5 + 44*4, width: self.view.bounds.size.width, height: 44)
		
		// populate screen
		self.populateData()
		
		NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: nil)
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
	}
	
	func deleteProject(){
		
	}
	
	func populateData(){
		if let project = Voila.shared.project{
			if let email = project.email{
				self.emailField.text = email
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
//		
//		let dateString = dateStringForUnixTime(userData["createdAt"] as! Double)
//		let timeString = timeStringForUnixTime(userData["createdAt"] as! Double)
//		
//		lockboxField.text = userData["email"] as? String
//		nameField.text = userData["displayName"] as? String
//		creationDateField.text = dateString + " " + timeString
//		detailField.text = userData["detail"] as? String
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
		// TODO: list all UITextFields here
		if let nameText = nameField.text{
			if let project = Voila.shared.project{
				project.name = nameText
				project.synchronize(completionHandler: nil)
			}
		}
		if let emailText = emailField.text{
			if let project = Voila.shared.project{
				project.email = emailText
				project.synchronize(completionHandler: nil)
			}
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

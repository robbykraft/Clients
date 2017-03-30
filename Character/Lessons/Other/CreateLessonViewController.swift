//
//  CreateLessonViewController.swift
//  Character
//
//  Created by Robby on 3/28/16.
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

class CreateLessonViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var data:Lesson?{
		didSet{
			let title:String = (data?.title)!
			let body:String = (data?.body)!
			let author:String = (data?.author)!
			
			let imageFilename = (data?.image)!
			Cache.shared.imageFromStorageBucket(imageFilename) { (image, requiredDownload) in
				self.imageView.image = image
			}
			
			let aText:NSMutableAttributedString = NSMutableAttributedString(string: title.uppercased())
			aText.addAttributes(Style.shared.heading1Attributes(), range: NSMakeRange(0, aText.length))
//			self.titleField.numberOfLines = 0
			self.titleField.attributedText = aText
			
			bodyText.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			bodyText.text = body
			
			authorField.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
			authorField.text = author
		}
	}
	
	let imageView = UIImageView()
	let imageButton = UIButton()
	let authorField = UITextField()
	let bodyText = UITextView()
	let titleField = UITextField()
	
	let authorHR1 = UIView()
	let authorHR2 = UIView()
	
	let scrollView = UIScrollView()
	
	let submitButton = UIButton()
	
	let fakeNavBar = UIView()
	let navTitle = UILabel()
	let closeButton = UIButton()
	let paperclip = UIImageView()
	
	var uploadedImageURL:String?

//	let imagePicker = UIImagePickerController() // hold onto the controller so we can dismiss it
	
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
		navTitle.text = "SUBMIT A LESSON"
		navTitle.textColor = UIColor.white
		closeButton.setTitle("×", for: .normal)
		closeButton.setTitleColor(UIColor.white, for: .normal)
		navTitle.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		closeButton.titleLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)

		
		scrollView.addSubview(imageView)
		scrollView.addSubview(paperclip)
		scrollView.addSubview(imageButton)
		scrollView.addSubview(authorField)
		scrollView.addSubview(bodyText)
		scrollView.addSubview(titleField)
		scrollView.addSubview(authorHR1)
		scrollView.addSubview(authorHR2)
		

		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = UIColor.white
		paperclip.image = UIImage.init(named: "paper-clip")
		paperclip.alpha = 0.33
		imageButton.backgroundColor = UIColor.clear
		titleField.textAlignment = .center
		titleField.backgroundColor = UIColor.white
		authorField.backgroundColor = UIColor.white
		authorField.textAlignment = .center
		authorField.textColor = Style.shared.lightBlue
		bodyText.isScrollEnabled = true
		bodyText.isEditable = true
		bodyText.dataDetectorTypes = .link
		authorHR1.backgroundColor = UIColor.black
		authorHR2.backgroundColor = UIColor.black
		
		titleField.placeholder = "Lesson Title"
		authorField.placeholder = "Attribution Source"

		imageButton.addTarget(self, action: #selector(imageButtonPress), for: .touchUpInside)
		closeButton.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)

		scrollView.backgroundColor = Style.shared.whiteSmoke

//		textView.delegate = self
//		textView.backgroundColor = UIColor.white
//		textView.returnKeyType = .done
//		textView.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

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
		
		
		let imgHeight:CGFloat = scrollView.frame.size.width * 175.0/300.0
		imageView.frame = CGRect(x: 0, y: navPad, width: scrollView.frame.size.width, height: imgHeight)
		imageButton.frame = imageView.frame
		paperclip.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
		paperclip.center = imageView.center
		
		// TITLE LABEL
		titleField.frame = CGRect(x: sidePad, y: navPad + imgHeight + 20, width: scrollView.frame.size.width - sidePad*2, height: 44)
		let titleHeight = titleField.frame.size.height
		
		// AUTHOR LABEL
		authorField.frame = CGRect(x: sidePad, y: titleField.frame.origin.y + titleHeight + 20, width: scrollView.frame.size.width - sidePad*2, height: 44)
		let authorHeight = authorField.frame.size.height
		
		// LESSON BODY
		bodyText.frame = CGRect(x: sidePad, y: authorField.frame.origin.y + authorHeight + 20, width: scrollView.frame.size.width - sidePad*2, height: scrollView.frame.size.height*0.5)
		let bodyHeight = bodyText.frame.size.height
		
		authorHR1.frame = CGRect(x: sidePad, y: authorField.frame.origin.y - 10, width: scrollView.frame.size.width - sidePad*2, height: 1)
		authorHR2.frame = CGRect(x: sidePad, y: authorField.frame.origin.y + authorHeight + 10, width: scrollView.frame.size.width - sidePad*2, height: 1)
		
//		scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: bodyText.frame.origin.y + bodyHeight + 20)
		
		submitButton.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: 44)
		submitButton.center = CGPoint(x: scrollView.center.x, y: bodyText.frame.origin.y + bodyHeight + 20 + 44)
		
		scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: submitButton.center.y + 60 )
		
	}

	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
//		UIApplication.shared.statusBarStyle = .lightContent

//		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
//		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
//	
//		let pad:CGFloat = 30
//		textView.frame = CGRect(x: pad, y: pad, width: scrollView.frame.size.width - pad*2, height: scrollView.frame.size.height - pad*2 - navBarHeight - tabBarHeight - statusBarHeight())

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
	
	
	func imageButtonPress(_ sender:UIButton){
		let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
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
	
	func closeButtonPress(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func submitButtonHandler(){
		// todo: make these options
		let pillarNumber = 0
		let gradeNumber = 0
		
		var userString:String = ""
		if let uid = Fire.shared.myUID {
			userString = uid
		}
		let lessonObject:[String:Any] = [
			"title": titleField.text ?? "",
			"text": bodyText.text,
			"lesson_author": authorField.text ?? "",
			"image": uploadedImageURL ?? "",
			"pillar": pillarNumber,
			"grade": gradeNumber,
			"createdAt": Date.init().timeIntervalSince1970,
			"user": userString
		]

		Fire.shared.newUniqueObjectAtPath("lesson", object: lessonObject as AnyObject) {
			let alertController = UIAlertController.init(title: "Lesson Submitted", message: "Thank you for contributing!", preferredStyle: .alert)
			let okayButton = UIAlertAction.init(title: "Okay", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			})
			alertController.addAction(okayButton)
			self.present(alertController, animated: true, completion: nil)
		}
		
	}
	
	
	func openImagePicker(_ sourceType:UIImagePickerControllerSourceType) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = sourceType
		self.present(imagePicker, animated: true, completion: nil)
//		self.navigationController?.present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let data = UIImageJPEGRepresentation(image, 0.5)
		if(data != nil){
			Fire.shared.uploadFileAndMakeRecord(data!, folder:"userSubmitted", fileType: .image_JPG, description: nil, completionHandler: { (downloadURL) in
				if(downloadURL != nil){
					self.uploadedImageURL = downloadURL!.absoluteString
					Cache.shared.profileImage[Fire.shared.myUID!] = image
					self.imageView.image = image
				}
			})
		}
		if(data == nil){
			print("image picker data is nil")
		}
		picker.dismiss(animated: true, completion: nil)
//		self.navigationController?.dismiss(animated: true, completion: nil)
	}


	
}

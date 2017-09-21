//
//  ProposalViewController.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MessageUI

class ProposalViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
	
	// for the ios keyboard covers textfield thing
	var activeField: UITextField?
	var keyboardSize: CGSize?
	
	let projectTitle = UILabel()
	let projectDescription = UILabel()
	let salesTaxLabel = UILabel()
	let discountLabel = UILabel()
	let discountField = UITextField()
	let salesTaxField = UITextField()
	let scrollView = UIScrollView()
	var roomLabels:[UILabel] = []
	var roomFields:[UITextField] = []
	let hr = UIView();

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Proposal"
		
		let sendButton = UIBarButtonItem.init(title: "Email", style: .done, target: self, action: #selector(sendProposal))
		self.navigationItem.rightBarButtonItem = sendButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)

        // Do any additional setup after loading the view.
		self.scrollView.frame = self.view.bounds
		self.view.addSubview(self.scrollView)
		self.scrollView.backgroundColor = Style.shared.athensGray
		buildPage()
		self.registerForKeyboardNotifications()
    }
	
	func buildPage(){
		if let project = Voila.shared.project{
			self.projectTitle.numberOfLines = 3
			self.projectTitle.text = project.name
			self.projectTitle.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P40)
			self.scrollView.addSubview(self.projectTitle)
			
			self.projectDescription.font = UIFont(name:SYSTEM_FONT, size:Style.shared.P24)
			self.projectDescription.text = "Total: $\(project.cost())"
			self.scrollView.addSubview(self.projectDescription)
	
			self.salesTaxLabel.font = UIFont(name:SYSTEM_FONT, size:Style.shared.P18)
			self.salesTaxLabel.text = "% sales tax"
			self.scrollView.addSubview(self.salesTaxLabel)
			self.discountLabel.font = UIFont(name:SYSTEM_FONT, size:Style.shared.P18)
			self.discountLabel.text = "$ discount"
			self.scrollView.addSubview(self.discountLabel)
			
			self.salesTaxField.backgroundColor = .white
			self.salesTaxField.textAlignment = .right
			self.salesTaxField.keyboardType = .decimalPad
			self.salesTaxField.placeholder = "0.0"
			self.salesTaxField.delegate = self
			self.salesTaxField.layer.cornerRadius = 5.0
			self.discountField.backgroundColor = .white
			self.discountField.textAlignment = .right
			self.discountField.keyboardType = .numberPad
			self.discountField.delegate = self
			self.discountField.layer.cornerRadius = 5.0
			self.scrollView.addSubview(self.discountField)
			self.scrollView.addSubview(self.salesTaxField)
			let insetPadding1 = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
			salesTaxField.rightView = insetPadding1
			salesTaxField.rightViewMode = .always
			let insetPadding2 = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
			discountField.rightView = insetPadding2
			discountField.rightViewMode = .always

			hr.backgroundColor = .black
			self.scrollView.addSubview(hr)
			
			for i in 0..<project.rooms.count{
				let room = project.rooms[i]
				
				let roomLabel = UILabel()
				let roomField = UITextField()
				roomLabel.text = room.name
				if let name = room.customName{ roomLabel.text = name }
				roomField.text = String(describing:room.getCost())
				roomField.tag = i
				roomField.backgroundColor = .white
				roomField.textAlignment = .right
				roomField.keyboardType = .numberPad
				roomField.delegate = self
				let insetPadding = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
				roomField.rightView = insetPadding
				roomField.rightViewMode = .always
				roomField.layer.cornerRadius = 5.0
				self.scrollView.addSubview(roomLabel)
				self.scrollView.addSubview(roomField)
				self.roomLabels.append(roomLabel)
				self.roomFields.append(roomField)
			}
		}
	}
	
	func updateCustomCosts(updateCompletion:(() -> ())?){
		if let project = Voila.shared.project{
			var change = false
			for textField in self.roomFields{
				let i = textField.tag
				if let fieldText = textField.text{
					if let thisCost = Int(fieldText){
						if thisCost != project.rooms[i].getCost(){
							project.rooms[i].cost = thisCost
							change = true
						}
					}
				}
			}
			if change == true{
				project.synchronize(completionHandler: {
					if let completion = updateCompletion{
						completion()
					}
				})
			} else{
				if let completion = updateCompletion{
					completion()
				}
			}
		}
	}
	
//	func textFieldDidEndEditing(_ textField: UITextField) {
//		let i = textField.tag
//		if let fieldText = textField.text{
//			if let newCost = Int(fieldText){
//				print(newCost)
//				if let project = Voila.shared.project{
//					let room = project.rooms[i]
//					room.cost = newCost
//					project.synchronize(completionHandler: nil)
//				}
//			}
//		}
//	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.updateCustomCosts(updateCompletion: nil)
	}

	deinit{
		self.deregisterFromKeyboardNotifications()
	}

	override func viewWillAppear(_ animated: Bool) {
		let padding:CGFloat = 15;
		self.projectTitle.frame = CGRect.init(x: padding, y: padding, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
		self.projectTitle.sizeToFit()
		
		self.projectDescription.frame = CGRect.init(x: padding, y: padding + self.projectTitle.bounds.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
		self.projectDescription.sizeToFit()
		
		self.salesTaxField.frame = CGRect.init(x: padding, y: 5 + projectDescription.frame.origin.y + self.projectDescription.bounds.size.height, width: self.view.bounds.size.width * 0.4, height:32)
		self.discountField.frame = CGRect.init(x: padding, y: 5 + salesTaxField.frame.origin.y + self.salesTaxField.bounds.size.height, width: self.view.bounds.size.width * 0.4, height:32)

		self.salesTaxLabel.frame = CGRect.init(x: padding + self.view.bounds.size.width * 0.5, y: 5 + projectDescription.frame.origin.y + self.projectDescription.bounds.size.height, width: self.view.bounds.size.width * 0.3, height:40)
		self.discountLabel.frame = CGRect.init(x: padding + self.view.bounds.size.width * 0.5, y: 5 + salesTaxField.frame.origin.y + self.salesTaxField.bounds.size.height, width: self.view.bounds.size.width * 0.3, height:40)

		let labelYStart:CGFloat = self.discountField.frame.origin.y + self.discountField.frame.size.height + padding

		hr.frame = CGRect(x: padding, y: labelYStart - padding*0.333, width: self.view.bounds.size.width-padding*2, height: 1)
		
		let labelW = self.view.bounds.size.width * 0.5
		let fieldW = self.view.bounds.size.width * 0.25
		var yPos = labelYStart
		for label in self.roomLabels{
			label.frame = CGRect(x: padding, y: yPos, width: labelW, height: 40)
			yPos += 50
		}
		yPos = labelYStart
		for field in self.roomFields{
			field.frame = CGRect(x: self.view.bounds.size.width-fieldW-padding, y: yPos, width: fieldW, height: 40)
			yPos += 50
		}
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: yPos)
	}

	func sendProposal(){
		self.view.endEditing(true)
		self.updateCustomCosts {
			Voila.shared.sendProposal(self)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
	
	
	
	func registerForKeyboardNotifications(){
		//Adding notifies on keyboard appearing
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func deregisterFromKeyboardNotifications(){
		//Removing notifies on keyboard appearing
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func keyboardWasShown(notification: NSNotification){
		//Need to calculate keyboard exact size due to Apple suggestions
//		self.scrollView.isScrollEnabled = true
		if self.keyboardSize == nil{
//			var info = notification.userInfo!
//			let keySize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
			self.keyboardSize = CGSize(width: self.view.bounds.size.width, height: 300)//keySize
		}
		if let activeField = self.activeField {
			let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
			let statusHeight:CGFloat = statusBarHeight()
//			let header = navBarHeight + statusHeight
			var newSize = self.view.bounds.size
			newSize.height += (self.keyboardSize?.height)!
			self.scrollView.contentSize = newSize
			let fieldFromBottom = (self.scrollView.bounds.size.height-activeField.frame.origin.y)
			print(fieldFromBottom)
			let scrollToY = newSize.height - 1 - fieldFromBottom
			self.scrollView.scrollRectToVisible(CGRect.init(x: 0, y: scrollToY, width: 1, height: 1), animated: true)
		}
	}
	
	func keyboardWillBeHidden(notification: NSNotification){
		self.scrollView.contentSize = self.view.bounds.size
		self.scrollView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
		self.view.endEditing(true)
//		self.scrollView.isScrollEnabled = false
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField){
		activeField = textField
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		Voila.shared.mailDidFinish(result)
		self.dismiss(animated: true, completion: nil)
	}

}

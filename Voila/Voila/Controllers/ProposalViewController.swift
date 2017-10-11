//
//  ProposalViewController.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MessageUI

class ProposalViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	
	// for the ios keyboard covers textfield thing
	var activeField: UITextField?
	var keyboardSize: CGSize?
	
	let projectTitle = UILabel()
//	let projectDescription = UILabel()

	let _0totalBeforeField = UITextField()
	let _1discountTextField = UITextField()
	let _2discountField = UITextField()
	let _3discountSummaryField = UITextField()
	let _4totalBeforeField = UITextField()
	let _5salesTaxField = UITextField()
	let _6salesTaxSummaryField = UITextField()
	let _7grandTotalField = UITextField()
	let _8renewalField = UITextField()
	let _9renewalSummaryField = UITextField()

	let _0totalBeforeLabel = UILabel()
	let _1discountLabel = UILabel()
	let _2discountPctLabel = UILabel()
	let _4totalBeforeLabel = UILabel()
	let _5salesTaxLabel = UILabel()
	let _7grandTotalLabel = UILabel()
	let _8renewalLabel = UILabel()

	let scrollView = UIScrollView()
	var roomLabels:[UILabel] = []
	var roomFields:[UITextField] = []
	let hr = UIView();
	
	// picker stuff
	let taxItems = ["Phila 8%", "PA 6%", "NJ 7%"]
	let discountTextItems = ["New Client", "Friends & Family", "Discount"]
	let discountItems = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
	let renewalItems = [2, 3, 4, 5, 6]
	let pickerTax = UIPickerView()
	let pickerDiscount = UIPickerView()
	let pickerDiscountText = UIPickerView()
	let pickerRenewal = UIPickerView()
	let pickerToolbar = UIToolbar()
	let numberToolbar = UIToolbar()

	var contentHeight:CGFloat = 0
	
	
	var updateTimer:Timer?  // live updates to profile entries, prevents updating too frequently



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
			
//			self.projectDescription.font = UIFont(name:SYSTEM_FONT, size:Style.shared.P24)
//			self.projectDescription.text = "Total: $\(project.cost())"
//			self.scrollView.addSubview(self.projectDescription)
			
			for label in [_0totalBeforeLabel, _1discountLabel, _2discountPctLabel, _4totalBeforeLabel, _5salesTaxLabel, _7grandTotalLabel, _8renewalLabel]{
				label.font = UIFont(name:SYSTEM_FONT, size:Style.shared.P18)
				label.textAlignment = .right
				self.scrollView.addSubview(label)
			}
			self._0totalBeforeLabel.text = "Total"
			self._1discountLabel.text = "Discount"
			self._2discountPctLabel.text = "%"
			self._4totalBeforeLabel.text = "Total Before Tax"
			self._5salesTaxLabel.text = "Sales Tax"
			self._7grandTotalLabel.text = "Grand Total"
			self._8renewalLabel.text = "Montly Renewals"

			for field in [self._0totalBeforeField, self._1discountTextField, self._2discountField, self._3discountSummaryField, self._4totalBeforeField, self._5salesTaxField, self._6salesTaxSummaryField, self._7grandTotalField, self._8renewalField, self._9renewalSummaryField]{
				field.backgroundColor = .clear
				field.textAlignment = .right
				field.layer.cornerRadius = 5.0
				let insetPadding = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
				field.rightView = insetPadding
				field.rightViewMode = .always
				self.scrollView.addSubview(field)
			}
			self._1discountTextField.text = discountTextItems.first
			self._2discountField.text = String(describing:discountItems.first!)
			self._5salesTaxField.text = taxItems.first
			self._8renewalField.text = String(describing:renewalItems.first!)
			self._1discountTextField.backgroundColor = .white
			self._2discountField.backgroundColor = .white
			self._5salesTaxField.backgroundColor = .white
			self._8renewalField.backgroundColor = .white
			
			self._0totalBeforeLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._0totalBeforeField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._4totalBeforeLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._4totalBeforeField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._7grandTotalLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._7grandTotalField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)

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
				roomField.inputAccessoryView = numberToolbar

				roomField.delegate = self
				let insetPadding = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
				roomField.rightView = insetPadding
				roomField.rightViewMode = .always
				roomField.layer.cornerRadius = 5.0
				roomField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
				self.scrollView.addSubview(roomLabel)
				self.scrollView.addSubview(roomField)
				self.roomLabels.append(roomLabel)
				self.roomFields.append(roomField)
			}
		}
		
		
		pickerToolbar.barStyle = .default
//		pickerToolbar.isTranslucent = true
		pickerToolbar.tintColor = Style.shared.blue
		pickerToolbar.sizeToFit()
		let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDone))
		pickerToolbar.items = [doneButton]
		pickerToolbar.isUserInteractionEnabled = true

		numberToolbar.barStyle = .default
		//		numberToolbar = true
		numberToolbar.tintColor = Style.shared.blue
		numberToolbar.sizeToFit()
		let doneButton2 = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(numberDone))
		numberToolbar.items = [doneButton2]
		numberToolbar.isUserInteractionEnabled = true

		for picker in [self.pickerTax, self.pickerDiscount, self.pickerDiscountText, self.pickerRenewal]{
			picker.delegate = self
			picker.backgroundColor = .white
			picker.dataSource = self
		}
		
		self._1discountTextField.inputView = self.pickerDiscountText
		self._1discountTextField.inputAccessoryView = pickerToolbar
		self._2discountField.inputView = self.pickerDiscount
		self._2discountField.inputAccessoryView = pickerToolbar
		self._5salesTaxField.inputView = self.pickerTax
		self._5salesTaxField.inputAccessoryView = pickerToolbar
		self._8renewalField.inputView = self.pickerRenewal
		self._8renewalField.inputAccessoryView = pickerToolbar

		self.updateTotals()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.updateCustomCosts(updateCompletion: nil)
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
		self.deregisterFromKeyboardNotifications()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		let padding:CGFloat = 15;
		self.projectTitle.frame = CGRect.init(x: padding, y: padding, width: self.view.bounds.size.width - padding*2, height: self.view.bounds.size.height)
		self.projectTitle.sizeToFit()
		
//		self.projectDescription.frame = CGRect.init(x: padding, y: padding + self.projectTitle.bounds.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
//		self.projectDescription.sizeToFit()
		
		let yPad:CGFloat = 5
		var i:CGFloat = 0
		let startY:CGFloat = projectTitle.frame.origin.y + self.projectTitle.bounds.size.height
		for field in [self._0totalBeforeField, self._1discountTextField, self._2discountField, self._3discountSummaryField, self._4totalBeforeField, self._5salesTaxField, self._6salesTaxSummaryField, self._7grandTotalField, self._8renewalField, self._9renewalSummaryField]{
			field.frame = CGRect.init(x: padding + self.view.bounds.size.width * 0.5, y: startY + (32+yPad)*i, width: self.view.bounds.size.width * 0.5-padding*2, height:32)
			i += 1
		}
		
		for label in [_0totalBeforeLabel, _1discountLabel, _2discountPctLabel, _4totalBeforeLabel, _5salesTaxLabel, _7grandTotalLabel, _8renewalLabel]{
			label.sizeToFit()
		}
		self._0totalBeforeLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 0,
		                                            width: self.view.bounds.size.width * 0.5 - 5, height:self._0totalBeforeLabel.bounds.size.height)
		self._1discountLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 1,
		                                         width: self.view.bounds.size.width * 0.5 - 5, height:self._1discountLabel.bounds.size.height)
		self._2discountPctLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 2,
		                                         width: self.view.bounds.size.width * 0.5 - 5, height:self._2discountPctLabel.bounds.size.height)
		self._4totalBeforeLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 4,
		                                            width: self.view.bounds.size.width * 0.5 - 5, height:self._4totalBeforeLabel.bounds.size.height)
		self._5salesTaxLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 5,
		                                         width: self.view.bounds.size.width * 0.5 - 5, height:self._5salesTaxLabel.bounds.size.height)
		self._7grandTotalLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 7,
		                                           width: self.view.bounds.size.width * 0.5 - 5, height:self._7grandTotalLabel.bounds.size.height)
		self._8renewalLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 8,
		                                        width: self.view.bounds.size.width * 0.5 - 5, height:self._8renewalLabel.bounds.size.height)
		
		// fix for iphone 5 size
//		self._1discountTextField.frame = CGRect.init(x: self.view.bounds.size.width * 0.5 - padding, y: startY + (32+yPad)*1, width: self.view.bounds.size.width * 0.5, height:32)
//		self._1discountLabel.frame = CGRect.init(x: 5, y: startY + 5 + (32+yPad) * 1,
//		                                         width: self.view.bounds.size.width * 0.5 - padding*2, height:self._1discountLabel.bounds.size.height)


		let labelYStart:CGFloat = self._9renewalSummaryField.frame.origin.y + self._9renewalSummaryField.frame.size.height + padding
		
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
		self.contentHeight = yPos
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: contentHeight)
	}

	func updateTotals(){
		
		if let project = Voila.shared.project{
			let rawCost = project.cost()
//			let taxItems = ["Phila 8%", "PA 6%", "NJ 7%"]
			var salesTax:Float = 0.08
			switch _5salesTaxField.text!{
			case taxItems[0]: salesTax = 0.08
			case taxItems[1]: salesTax = 0.06
			case taxItems[2]: salesTax = 0.07
			default: salesTax = 0.08
			}
			let discount:Float = Float(_2discountField.text!)!
			let renewal:Float = Float(_8renewalField.text!)!
			let discountAmount:Int = Int(discount * 0.01 * Float(rawCost))
			let totalBefore2:Int = rawCost - discountAmount
			let salesTaxSum:Int = Int(Float(totalBefore2) * salesTax)
			let grandTotal:Int = totalBefore2 + salesTaxSum
			let grandTotalRounded:Int = Int(Float(grandTotal)*0.01)*100
			let renewalCost:Int = Int(Float(grandTotal)*0.3333 * renewal)
			
			project.discountTotal = discountAmount
			project.discountPct = Int(discount)
			project.discountText = _1discountTextField.text
			project.taxPct = salesTax
			project.taxTotal = salesTaxSum
			project.renewalsTotal = renewalCost

			self._0totalBeforeField.text = "$\(rawCost)"
//			self._1discountTextField.text = "%\(discount)"
//			self._2discountField.text = "$\(rawCost)"
			self._3discountSummaryField.text = "$\(discountAmount)"
			self._4totalBeforeField.text = "$\(totalBefore2)"
//			self._5salesTaxField.text = "$\(rawCost)"
			self._6salesTaxSummaryField.text = "$\(salesTaxSum)"
			self._7grandTotalField.text = "$\(grandTotalRounded)"
//			self._8renewalField.text = "$\(rawCost)"
			self._9renewalSummaryField.text = "$\(renewalCost)"
			
		}
		
//		if let project = Voila.shared.project{
//			let rawCost = project.cost()
//			let adjustedCost = Float(rawCost) + Float(rawCost) * salesTax * 0.01 - discount
//			let adjustedInt = Int(adjustedCost*0.01) * 100
//			self.projectDescription.text = "Total: $\(adjustedInt) (from \(rawCost))"
//		}
	}
	
	func pickerDone(){
		self._1discountTextField.resignFirstResponder()
		self._2discountField.resignFirstResponder()
		self._5salesTaxField.resignFirstResponder()
		self._8renewalField.resignFirstResponder()
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: contentHeight)
		self.updateTotals()
	}
	
	func numberDone(){
		for field in self.roomFields {
			field.resignFirstResponder()
		}
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: contentHeight)
		self.updateCustomCosts {
			self.updateTotals()
		}
	}


	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView{
		case self.pickerDiscountText: return self.discountTextItems.count
		case self.pickerDiscount: return self.discountItems.count
		case self.pickerTax: return self.taxItems.count
		case self.pickerRenewal: return self.renewalItems.count
		default: return 0
		}
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView{
		case self.pickerDiscountText: return self.discountTextItems[row]
		case self.pickerDiscount: return String(describing:self.discountItems[row])
		case self.pickerTax: return self.taxItems[row]
		case self.pickerRenewal: return String(describing:self.renewalItems[row])
		default: return ""
		}
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch pickerView{
		case self.pickerDiscountText: self._1discountTextField.text = self.discountTextItems[row]
		case self.pickerDiscount: self._2discountField.text = String(describing:self.discountItems[row])
		case self.pickerTax: self._5salesTaxField.text = self.taxItems[row]
		case self.pickerRenewal: self._8renewalField.text = String(describing:self.renewalItems[row])
		default: break
		}
		self.updateTotals()
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
	
	func textFieldDidChange(textField: UITextField){
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	func updateWithDelay() {
		// TODO: list all UITextFields here
		self.updateCustomCosts {
			self.updateTotals()
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
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
			var newSize = self.scrollView.bounds.size
			newSize.height += abs((self.keyboardSize?.height)!) + 300
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

//
//  ProposalViewController.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MessageUI

class ProposalViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMessageComposeViewControllerDelegate {
	
	// for the ios keyboard covers textfield thing
	var activeField: UITextField?
	var keyboardSize: CGSize?
	
	let projectTitle = UILabel()

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
	var roomContents:[UILabel] = []
	var roomFields:[UITextField] = []
	let hr = UIView();
	
	// picker stuff
	let taxItems = ["Phila 8%", "PA 6%", "NJ 7%", "0%"]
	let discountTextItems = ["No Discount", "New Client", "Friends & Family", "Discount"]
	let discountItems = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
//	let renewalItems = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43 ,44, 45, 46, 47, 48, 49 ,50]
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

		let sendButton = UIBarButtonItem.init(title: "Send", style: .done, target: self, action: #selector(sendProposal))
		self.navigationItem.rightBarButtonItem = sendButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSAttributedString.Key.foregroundColor: Style.shared.highlight], for:.normal)

        // Do any additional setup after loading the view.
		self.scrollView.frame = self.view.bounds
		self.view.addSubview(self.scrollView)
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.scrollView.backgroundColor = Style.shared.whiteSmoke
		buildPage()
		self.registerForKeyboardNotifications()
    }
	
	func buildPage(){
		if let project = Voila.shared.project{

			self.projectTitle.numberOfLines = 3
			self.projectTitle.text = project.name
			self.projectTitle.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P40)
			self.scrollView.addSubview(self.projectTitle)

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
			self._8renewalLabel.text = "Monthly Renewal %"

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
			self._8renewalField.text = "33"
			self._1discountTextField.backgroundColor = .white
			self._2discountField.backgroundColor = .white
			self._5salesTaxField.backgroundColor = .white
			self._8renewalField.backgroundColor = .white


			self._0totalBeforeField.isEnabled = false
			self._3discountSummaryField.isEnabled = false
			self._4totalBeforeField.isEnabled = false
			self._6salesTaxSummaryField.isEnabled = false
			self._7grandTotalField.isEnabled = false
			self._9renewalSummaryField.isEnabled = false

			self._8renewalField.keyboardType = .numberPad

			self._0totalBeforeLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._0totalBeforeField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._4totalBeforeLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._4totalBeforeField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._7grandTotalLabel.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)
			self._7grandTotalField.font = UIFont(name:SYSTEM_FONT_B, size:Style.shared.P18)

			hr.backgroundColor = .black
			self.scrollView.addSubview(hr)

			if project.discountTotal != nil{
				self._1discountTextField.text = String(describing:project.discountTotal!)
			}
			if project.discountPct != nil{
				_2discountField.text = String(describing: project.discountPct!)
			}
			if project.discountText != nil{
				_1discountTextField.text = project.discountText!
			}
			if project.taxPct != nil{
				switch project.taxPct!{
				case 0.08: _5salesTaxField.text = taxItems[0]
				case 0.06: _5salesTaxField.text = taxItems[1]
				case 0.07: _5salesTaxField.text = taxItems[2]
				case 0.0: _5salesTaxField.text = taxItems[3]
				default: _5salesTaxField.text = taxItems[0];
				}
			}
			if project.renewalsPct != nil {
				self._8renewalField.text = String(describing:project.renewalsPct!)
			}

			for i in 0..<project.rooms.count{
				let room = project.rooms[i]

				let roomLabel = UILabel()
				let roomField = UITextField()
				let roomFurniture = UILabel()
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

				roomFurniture.numberOfLines = room.furniture.count
				roomFurniture.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P12)
				
//				let furniture = room.furniture.sorted(by: { $0.name < $1.name })
//				var furnitureString = ""
//				for i in 0..<furniture.count {
//					let thisString = "\n" + furniture[i].name + " " + String(describing: furniture[i].copies)
//					furnitureString += thisString
//				}
//				roomFurniture.text = furnitureString
				roomFurniture.text = "chair 1\nfield recorder 1\npeace lamp 2\nchair 4"
				
//				roomFurniture.text = room.furniture
//					.sorted(by: { $0.name < $1.name })
//					.map({$0.name + " " + String(describing:$0.copies)})
//					.reduce("", { (a, b) -> String in
//						a + "\n" + b
//					})

				
				
//				roomFurniture.text = room.furniture
//					.compactMap({ $0.name })
//					.joined(separator: ", ")
				
//				roomFurniture.text = room.furniture.map({
//					$0.name + " " + String(describing:$0.copies)
//				}).joined(separator: " ")
				
				self.scrollView.addSubview(roomLabel)
				self.scrollView.addSubview(roomFurniture)
				self.scrollView.addSubview(roomField)
				self.roomLabels.append(roomLabel)
				self.roomContents.append(roomFurniture)
				self.roomFields.append(roomField)
			}
		}


		pickerToolbar.barStyle = .default
		pickerToolbar.tintColor = Style.shared.highlight
		pickerToolbar.sizeToFit()
		let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDone))
		pickerToolbar.items = [doneButton]
		pickerToolbar.isUserInteractionEnabled = true

		numberToolbar.barStyle = .default
		numberToolbar.tintColor = Style.shared.highlight
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
//		self._8renewalField.inputView = self.pickerRenewal
		self._8renewalField.inputAccessoryView = numberToolbar

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
		                                        width: self.view.bounds.size.width * 0.5, height:self._8renewalLabel.bounds.size.height)

		// trying something new here
		guard let project = Voila.shared.project else { return }
		for i in 0..<project.rooms.count{
			let room = project.rooms[i]
			let roomFurniture = self.roomContents[i]
			roomFurniture.text = room.furniture
				.sorted(by: { $0.name < $1.name })
				.map({$0.name + " " + String(describing:$0.copies)})
				.reduce("", { (a, b) -> String in
					a + "\n" + b
				})
		}
		// end experiment

		for contents in self.roomContents{
			contents.sizeToFit()
		}

		let labelYStart:CGFloat = self._9renewalSummaryField.frame.origin.y + self._9renewalSummaryField.frame.size.height + padding

		hr.frame = CGRect(x: padding, y: labelYStart - padding*0.333, width: self.view.bounds.size.width-padding*2, height: 1)

		let labelW = self.view.bounds.size.width * 0.5
		let fieldW = self.view.bounds.size.width * 0.25
		var yPos = labelYStart
//		for label in self.roomLabels{
//			label.frame = CGRect(x: padding, y: yPos, width: labelW, height: 40)
//			yPos += 50
//		}
//		yPos = labelYStart
//		for field in self.roomFields{
//			field.frame = CGRect(x: self.view.bounds.size.width-fieldW-padding, y: yPos, width: fieldW, height: 40)
//			yPos += 50
//		}

		for i in 0..<self.roomLabels.count{
			let label = self.roomLabels[i]
			let field = self.roomFields[i]
			let contents = self.roomContents[i]
			label.frame = CGRect(x: padding, y: yPos, width: labelW, height: 40)
			field.frame = CGRect(x: self.view.bounds.size.width-fieldW-padding, y: yPos, width: fieldW, height: 40)
			contents.frame = CGRect(x: padding*2, y: yPos+25, width: contents.frame.size.width, height: contents.frame.size.height)
			yPos += 50 + contents.frame.size.height
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
			case taxItems[3]: salesTax = 0.0
			default: salesTax = 0.08
			}
			let discount:Float = Float(_2discountField.text!)!
			let renewal:Float = Float(_8renewalField.text!)!  // percent number
			let discountAmount:Int = Int(round(discount * 0.01 * Float(rawCost)))
			let totalBefore2:Int = rawCost - discountAmount
			let salesTaxSum:Int = Int(round(Float(totalBefore2) * salesTax))
			let grandTotal:Int = totalBefore2 + salesTaxSum
//			let grandTotalRounded:Int = Int(Float(grandTotal)*0.01)*100
			let grandTotalRounded:Int = grandTotal
			let renewalCost:Int = Int(round(Float(grandTotal) * renewal * 0.01))
			
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
	
	@objc func pickerDone(){
		self._1discountTextField.resignFirstResponder()
		self._2discountField.resignFirstResponder()
		self._5salesTaxField.resignFirstResponder()
		self._8renewalField.resignFirstResponder()
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: contentHeight)
		self.updateCustomCosts {
			self.updateTotals()
		}
	}
	
	@objc func numberDone(){
		for field in self.roomFields {
			field.resignFirstResponder()
		}
		self._8renewalField.resignFirstResponder()
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
		default: return 0
		}
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView{
		case self.pickerDiscountText: return self.discountTextItems[row]
		case self.pickerDiscount: return String(describing:self.discountItems[row])
		case self.pickerTax: return self.taxItems[row]
		default: return ""
		}
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch pickerView{
		case self.pickerDiscountText: self._1discountTextField.text = self.discountTextItems[row]
		case self.pickerDiscount: self._2discountField.text = String(describing:self.discountItems[row])
		case self.pickerTax: self._5salesTaxField.text = self.taxItems[row]
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


			let rawCost = project.cost()
			var salesTax:Float = 0.08
			switch _5salesTaxField.text!{
			case taxItems[0]: salesTax = 0.08
			case taxItems[1]: salesTax = 0.06
			case taxItems[2]: salesTax = 0.07
			case taxItems[3]: salesTax = 0.0
			default: salesTax = 0.08
			}
			let discount:Float = Float(_2discountField.text!)!
			let renewal:Int = Int(_8renewalField.text!)!  // percent number
			let discountAmount:Int = Int(round(discount * 0.01 * Float(rawCost)))
			let totalBefore2:Int = rawCost - discountAmount
			let salesTaxSum:Int = Int(round(Float(totalBefore2) * salesTax))
			let grandTotal:Int = totalBefore2 + salesTaxSum
			let renewalCost:Int = Int(round(Float(grandTotal) * Float(renewal) * 0.01))

			if project.discountTotal != nil || project.discountTotal != discountAmount{
				project.discountTotal = discountAmount
				change = true
			}
			if project.discountPct == nil || project.discountPct != Int(discount){
				project.discountPct = Int(discount)
				change = true
			}
			if project.discountText != nil || project.discountText != _1discountTextField.text{
				project.discountText = _1discountTextField.text
				change = true
			}
			if project.taxPct != nil || project.taxPct != salesTax{
				project.taxPct = salesTax
				change = true
			}
			if project.taxTotal != nil || project.taxTotal != salesTaxSum{
				project.taxTotal = salesTaxSum
				change = true
			}
			if project.renewalsTotal != nil || project.renewalsTotal != renewalCost{
				project.renewalsTotal = renewalCost
				change = true
			}
			if project.renewalsPct != nil || project.renewalsPct != renewal{
				project.renewalsPct = renewal
				change = true
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
	
	@objc func textFieldDidChange(textField: UITextField){
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	@objc func updateWithDelay() {
		// TODO: list all UITextFields here
		self.updateCustomCosts {
			self.updateTotals()
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	@objc func sendProposal(){
		self.view.endEditing(true)
		
		let alert = UIAlertController.init(title: "Send proposal over", message: nil, preferredStyle: .actionSheet)
		let emailAction = UIAlertAction(title: "Email", style: .default) { (action) in
			self.updateCustomCosts {
				ProposalMaker.shared.sendEmailProposal(self)
			}
		}
		let textAction = UIAlertAction(title: "Text", style: .default) { (action) in
			self.updateCustomCosts {
				ProposalMaker.shared.sendMMSProposal(self)
			}
		}
		let disregardAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			alert.dismiss(animated: true, completion: nil)
		}
		alert.addAction(emailAction)
		alert.addAction(textAction)
		alert.addAction(disregardAction)
		self.present(alert, animated: true, completion: nil)
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
		if let activeField = self.activeField {
			var newSize = self.scrollView.contentSize
			newSize.height += 300
			self.scrollView.contentSize = newSize
			let fieldFromBottom = (self.scrollView.bounds.size.height-activeField.frame.origin.y)
			let scrollToY = newSize.height - 1 - fieldFromBottom
			self.scrollView.scrollRectToVisible(CGRect.init(x: 0, y: scrollToY, width: 1, height: 1), animated: true)
		}
	}
	
	@objc func keyboardWillBeHidden(notification: NSNotification){
		self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: contentHeight)
		self.view.endEditing(true)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField){
		activeField = textField
		textField.selectAll(self)
	}

	
	// forward delegate calls back to the singleton... little weird.
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		ProposalMaker.shared.mailDidFinish(result)
		self.dismiss(animated: true, completion: nil)
	}
	
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		ProposalMaker.shared.messageDidFinish(result)
		self.dismiss(animated: true, completion: nil)
	}


}


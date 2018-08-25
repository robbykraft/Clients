//
//  Preferences.swift
//  Allergy
//
//  Created by Robby on 4/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class Preferences: UITableViewController {
	
	let levelNames = ["NONE", "LOW", "MEDIUM", "HEAVY", "VERY HEAVY"]
	
	var isLocalEnabled = false
	var isLocalTimerRunning = false
	
	let timeInputView = UIView()
	
	var timeInputTextField:UITextField?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "PREFERENCES"
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

		self.navigationItem.rightBarButtonItem = newBackButton

		let font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18) ?? UIFont.boldSystemFont(ofSize: Style.shared.P18)
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: Style.shared.blue], for:.normal)
		
		PollenNotifications.shared.isLocalEnabled { (isEnabled) in
			self.isLocalEnabled = isEnabled
			self.tableView.reloadData()
		}
		PollenNotifications.shared.isLocalTimerRunning { (isRunning) in
			self.isLocalTimerRunning = isRunning
			self.tableView.reloadData()
		}
		
		// time picker input accessory
		let toolbar = UIToolbar().ToolbarPicker(mySelect: #selector(dismissPicker))
		let datePickerView = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.time

		datePickerView.addTarget(self, action: #selector(datePickerDidUpdate), for: .valueChanged)

		let (hour, minute) = PollenNotifications.shared.getNotificationTime()
		datePickerView.setDate(Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!, animated: false)
		timeInputView.backgroundColor = Style.shared.whiteSmoke
		let dW:CGFloat = self.view.frame.size.width - datePickerView.frame.size.width
		timeInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: datePickerView.frame.size.height + toolbar.frame.size.height)
		timeInputView.addSubview(toolbar)
		timeInputView.addSubview(datePickerView)
		datePickerView.frame.origin = CGPoint(x: dW*0.5, y: toolbar.frame.size.height)
    }
	
	@objc func datePickerDidUpdate(sender:UIDatePicker){
		let hour = Calendar.current.component(.hour, from: sender.date)
		let minute = Calendar.current.component(.minute, from: sender.date)
		PollenNotifications.shared.setNotificationTime(hour: hour, minute: minute)
		if let textField = timeInputTextField{
			let formatter = DateFormatter()
			formatter.dateFormat = "h:mm a"
			textField.text = formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!)
		}
	}
	
	@objc func dismissPicker() {
		view.endEditing(true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 60
		}
		return 44
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
//		return 4
		// for testing
		return 5
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section{
		case 0: return "Personalize Allergies"
		case 1: return "Daily Clinic Pollen Report"
		case 2: return "Symptom Tracking"
		default: return nil
		}
	}
	
		
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
//			if let pn = Pollen.shared.notifications["enabled"] as? Bool{
//				if pn == true{
//					return 3
//				}
//			}
			return 1
		case 2:
			return 2
		case 3:
			return 1
		// for testing
		case 4: return 1
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "PreferencesCell")
		
		let selectionView = UIView()
		selectionView.backgroundColor = Style.shared.athensGray
		cell.selectedBackgroundView = selectionView

		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "My Allergies"
		case 1:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Push Notification"

				switch UIApplication.shared.isRegisteredForRemoteNotifications {
				case true:
					cell.detailTextLabel?.textColor = Style.shared.blue
					cell.detailTextLabel?.text = "Enabled"
				case false:
					cell.detailTextLabel?.textColor = UIColor.lightGray
					cell.detailTextLabel?.text = "Disabled"
				}

//				if let pn = Pollen.shared.notifications["enabled"] as? Bool{
//					if pn == true{
//						cell.detailTextLabel?.textColor = Style.shared.blue
//						cell.detailTextLabel?.text = "Enabled"
//					} else if pn == false{
//						cell.detailTextLabel?.textColor = UIColor.lightGray
//						cell.detailTextLabel?.text = "Disabled"
//					}
//				}
			case 1:
				cell.selectionStyle = .none
				var pn:[String:Any] = Pollen.shared.notifications
				if let level = pn["level"] as? Int{
					cell.textLabel?.text = "notify for " + levelNames[level] + " or above"
				}
			case 2: break
//				let sliderCell = SliderTableViewCell()
//				sliderCell.selectionStyle = .none
//				sliderCell.delegate = self
//				var pn:[String:Any] = Pollen.shared.notifications
//				if let level = pn["level"] as? Int{
//					sliderCell.slider.value = (Float(level) + 0.5) / 4.99
//				}
//
//				return sliderCell
			default: break
			}
		case 2:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Daily Tracking"
				
				if isLocalEnabled && isLocalTimerRunning{
					cell.detailTextLabel?.textColor = Style.shared.blue
					cell.detailTextLabel?.text = "Enabled"
				} else{
					cell.detailTextLabel?.textColor = UIColor.lightGray
					cell.detailTextLabel?.text = "Disabled"
				}
			case 1:
				let cellTime = TextFieldTableViewCell.init(style: .default, reuseIdentifier: "TimeCell")
				cellTime.textLabel?.text = "Time"
				let (hour, minute) = PollenNotifications.shared.getNotificationTime()
				let formatter = DateFormatter()
				formatter.dateFormat = "h:mm a"
				cellTime.textField.text = formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!)
				cellTime.textField.inputAccessoryView = timeInputView
				timeInputTextField = cellTime.textField
				return cellTime
			case 2:
				cell.textLabel?.text = "Seasons"
				cell.detailTextLabel?.text = "All"
			default: break
			}
		case 3:
			cell.textLabel?.text = "About Allergy Free Austin"
		// for testing
		case 4:
			cell.textLabel?.text = "[ Generate test data ]"
		default: break
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				self.navigationController?.pushViewController(MyAllergies.init(style: .grouped), animated: true)
			default:
				break
			}
		case 1:
			switch indexPath.row {
			case 0:
				self.tableView.deselectRow(at: indexPath, animated: true)
				let alert = UIAlertController.init(title: "Push Notifications", message: "Push Notifications are enabled in Settings", preferredStyle: .alert)
				let action1 = UIAlertAction.init(title: "Close", style: .cancel, handler: { (action) in
					
				})
				let action2 = UIAlertAction.init(title: "Open Settings", style: .destructive, handler: { (action) in
					if let settingsURL = URL(string: UIApplicationOpenSettingsURLString){
						UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
					} else{
						print("settings not available")
					}
				})
				alert.addAction(action1)
				alert.addAction(action2)
				self.present(alert, animated: true, completion: nil)
//				var pn:[String:Any] = Pollen.shared.notifications
//				if let enabled = pn["enabled"] as? Bool{
//					pn["enabled"] = !enabled
//				}
//				Pollen.shared.notifications = pn
//				self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
				break
			default:
				break
			}
		case 2:
			if indexPath.row == 0{
				if isLocalEnabled{
					if isLocalTimerRunning{
						PollenNotifications.shared.disableLocalTimer()
						self.isLocalTimerRunning = false
						self.tableView.reloadData()
					} else{
						PollenNotifications.shared.enableLocalTimer { (isRunning) in
							self.isLocalTimerRunning = isRunning
							self.tableView.reloadData()
						}
					}
				} else{
					PollenNotifications.shared.enableLocalNotifications { (isEnabled) in
						self.isLocalEnabled = isEnabled
						PollenNotifications.shared.enableLocalTimer(completionHandler: { (isRunning) in
							self.isLocalTimerRunning = isRunning
							self.tableView.reloadData()
						})
					}
				}
			}
		case 3:
			self.navigationController?.pushViewController(AboutPage.init(style: .grouped), animated: true)
		// test
		case 4:
			Symptom.shared.clearDataAndMakeFakeData()
			self.tableView.deselectRow(at: indexPath, animated: true)
		default:
			break
		}
	}
	
	func didMoveSlider(sender: UISlider) {
		let newLevel:Int = Int(floor(sender.value * 4.99))
		var pn:[String:Any] = Pollen.shared.notifications
		pn["level"] = newLevel
		Pollen.shared.notifications = pn
		self.tableView.reloadRows(at: [IndexPath.init(row: 1, section: 1)], with: .none)
	}
	
	@objc func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIToolbar {
	
	func ToolbarPicker(mySelect : Selector) -> UIToolbar {
		
		let toolBar = UIToolbar()
		
		toolBar.barStyle = UIBarStyle.default
//		toolBar.isTranslucent = true
		toolBar.backgroundColor = Style.shared.athensGray
		toolBar.tintColor = UIColor.black
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
		doneButton.tintColor = Style.shared.blue
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		toolBar.setItems([ spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		return toolBar
	}
	
}

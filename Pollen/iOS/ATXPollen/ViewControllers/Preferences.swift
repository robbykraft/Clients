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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "PREFERENCES"
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

		self.navigationItem.rightBarButtonItem = newBackButton

		let font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18) ?? UIFont.boldSystemFont(ofSize: Style.shared.P18)
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: Style.shared.blue], for:.normal)

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
		return 3
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section{
		case 0: return "Personalized Allergy Report"
		case 1: return "Push Notifications"
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
			return 1
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
				cell.textLabel?.text = "Notifications"

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
			cell.textLabel?.text = "About Allergy Free Austin"
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
			self.navigationController?.pushViewController(AboutPage.init(style: .grouped), animated: true)
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

//
//  Settings.swift
//  Allergy
//
//  Created by Robby on 4/6/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AboutPage: UITableViewController{
	
	let logoImageView = UIImageView()

	var phoneNumberString:String?{
		didSet{ self.tableView.reloadData() }
	}
	var addressString:String?{
		didSet{ self.tableView.reloadData() }
	}
	var websiteString:String?{
		didSet{ self.tableView.reloadData() }
	}
	var hours:[[String:Any]]?{
		didSet{ self.tableView.reloadData()}
	}

	override func viewDidLoad() {
		self.title = "ABOUT US"

		logoImageView.image = UIImage(named: "logo")
		self.view.addSubview(logoImageView)
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		Database.database().reference().child("clinic/").observeSingleEvent(of: .value) { (data) in
			if let d = data.value as? [String:Any]{
				self.phoneNumberString = d["phone"] as? String
				self.websiteString = d["website"] as? String
				self.addressString = d["address"] as? String
				self.hours = d["hours"] as? [[String:Any]]
			}
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
		if(cell != nil){
			let cellY = (cell?.frame.origin.y)! + (cell?.frame.size.height)!
			let screenH = self.view.frame.size.height - 44 - 22
			let padding:CGFloat = self.view.frame.size.width*0.1
			var imageSize = screenH - cellY
			if(imageSize > self.view.frame.size.width){
				imageSize = self.view.frame.size.width
			}
			imageSize -= padding * 2
			logoImageView.frame = CGRect(x:0, y:0, width: imageSize, height: imageSize)
			logoImageView.center = CGPoint(x: 0.5 * self.view.frame.size.width, y: cellY + padding + imageSize*0.5)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 60
		}
		return 44
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Contact Us"
		case 1:
			return "Visit Us"
		default:
		return nil
		}
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section{
		case 0: return 2
		case 1:
			if let d = self.hours{
				return 1 + d.count
			}
			return 1
		default: return 0
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = UITableViewCell.init(style: .value1, reuseIdentifier: "AboutCell")
		if (indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 1 && indexPath.row == 0){
			cell = CenteredTableViewCell.init(style: .value1, reuseIdentifier: "CenteredCell")
		}
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)

		let selectionView = UIView()
		selectionView.backgroundColor = Style.shared.athensGray
		cell.selectedBackgroundView = selectionView
		cell.detailTextLabel?.textColor = UIColor.black

		cell.textLabel?.text = ""
		cell.detailTextLabel?.text = ""

		switch indexPath.section{
		case 0:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Phone"
				if let phone = self.phoneNumberString{
					cell.detailTextLabel?.text = phone
				}
			case 1:
				if let web = self.websiteString{
					cell.detailTextLabel?.text = web
				}
			default:
				break
			}
		case 1:
			cell.selectionStyle = .none
			switch indexPath.row {
			case 0:
				if let addy = self.addressString{
					cell.detailTextLabel?.text = addy
				}
			default:
				if let d = self.hours{
					if(d.count > indexPath.row-1){
						cell.textLabel?.text = d[indexPath.row-1]["days"] as? String
						cell.detailTextLabel?.text = d[indexPath.row-1]["times"] as? String
					}
				}
			}
		default:
			break
		}

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0{
			if(indexPath.row == 0){
				if var phone = self.phoneNumberString{
					phone = phone.replacingOccurrences(of: ".", with: "")
					if let phoneURL = URL(string: "tel://" + phone){
						UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
					} else{
						print("can't open phone number URL")
					}
				}
			} else if indexPath.row == 1{
				if let webby = self.websiteString{
					if let webURL = URL(string: "http://" + webby){
						UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
					} else{
						print("can't open website URL")
					}
				}
			}
		} else{
			
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

//
//  Settings.swift
//  Allergy
//
//  Created by Robby on 4/6/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class MyAllergies: UITableViewController{
	
	var sections:[[String]] = []  // array of arrays. 1:number of sections, 2:array of keys in each section
	
	var data:[String:Bool]?{ // key, value
		didSet{
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		self.title = "MY ALLERGIES"
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		rebuildData()
	}
	
	func rebuildData(){
		// seasons and categories are both 4 long
		self.sections = [ [], [], [], [] ]
		
		let myAllergies = Pollen.shared.myAllergies
		let keys = Array(myAllergies.keys)
		var dataKeys:[String:Bool] = [:]
		for key in keys{
			var section:Int = 0
			switch Pollen.shared.sortAllergiesBy {
			case 0:
				// sort by seasons
				if let t = Pollen.shared.types[key] as? [String:Any]{
					if let season = t["season"] as? Int{
						section = season
					}
				}
			default:
				// sort by species categories
				if let t = Pollen.shared.types[key] as? [String:Any]{
					if let group = t["group"] as? Int{
						section = group
					}
				}
			}
			let value = myAllergies[key]!
			dataKeys[key] = value
			self.sections[section].append(key)
		}
		for i in 0..<self.sections.count{
			self.sections[i] = self.sections[i].sorted(by: { (s1, s2) -> Bool in
				return s1 < s2
			})
		}
		self.data = dataKeys
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 60
		}
		return 44
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Pollen.shared.sortAllergiesBy {
		case 0:
			switch section{
			case 0: return nil
			case 1: return "Spring"
			case 2: return "Summer"
			case 3: return "Autumn"
			case 4: return "Winter"
			default: return nil
			}
		default:
			switch section{
			case 0: return nil
			case 1: return "Trees"
			case 2: return "Grasses"
			case 3: return "Molds"
			case 4: return "Weeds"
			default: return nil
			}
		}
	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count + 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			return 1
		}
		
		if section < sections.count + 1 {
			return sections[section-1].count
		}
		
		return 0
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "MyAllergiesCell")
		cell.textLabel?.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P18)
		cell.detailTextLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)

		let selectionView = UIView()
		selectionView.backgroundColor = Style.shared.athensGray
		cell.selectedBackgroundView = selectionView

		if indexPath.section == 0{
			cell.textLabel?.text = "Sort by"
			cell.detailTextLabel?.textColor = UIColor.black
			switch Pollen.shared.sortAllergiesBy {
			case 0:  cell.detailTextLabel?.text = "Seasons"
			default: cell.detailTextLabel?.text = "Groups"
			}
			return cell
		}
		
		if let d = self.data{
			if indexPath.section-1 < self.sections.count{
				if indexPath.row < self.sections[indexPath.section-1].count{
					let key = self.sections[indexPath.section-1][indexPath.row]
					let value = d[key]
					cell.textLabel?.text = Pollen.shared.nameFor(key: key)
					if(value == true){
						cell.textLabel?.textColor = UIColor.black
						cell.detailTextLabel?.text = "Include"
						cell.detailTextLabel?.textColor = Style.shared.blue
					}else{
						cell.textLabel?.textColor = UIColor.gray
						cell.detailTextLabel?.text = "Ignore"
						cell.detailTextLabel?.textColor = UIColor.lightGray
					}
					
				}
			}
		}
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0{
			if Pollen.shared.sortAllergiesBy == 0 {Pollen.shared.sortAllergiesBy = 1}
			else { Pollen.shared.sortAllergiesBy = 0 }
			rebuildData()
		} else{
			if var d = self.data{
				if indexPath.section - 1 < self.sections.count{
					if indexPath.row < self.sections[indexPath.section-1].count{
						let key = self.sections[indexPath.section-1][indexPath.row]
						var value = d[key]!
						value = !value
						Pollen.shared.myAllergies[key] = value
						self.data![key] = value
//						self.tableView.reloadData()
						self.tableView.reloadRows(at: [indexPath], with: .none)
						self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
						self.tableView.deselectRow(at: indexPath, animated: true)
					}
				}
			}
		}
	}
}

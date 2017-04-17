//
//  PillarOrderViewController.swift
//  Login
//
//  Created by Robby
//  Copyright © 2017 Robby. All rights reserved.
//

import UIKit

class PillarOrderTableViewController: UITableViewController, PillarSwitchDelegate {
	
	var customizeOrder = false

	let ps = PillarSwitchTableViewCell()
	
	var pillarStartTimes:[Int] = []{
		didSet{
			self.tableView.reloadData()
		}
	}
	var pillarOrder:[Int] = []{
		didSet{
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		self.tableView.isEditing = true
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.title = "PILLAR ORDER"
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
		
		getPillarSchedule()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	func getPillarSchedule(){
		self.pillarStartTimes = Schedule.shared.pillarStartTimeStamps
		print("self.pillarStartTimes")
		print(self.pillarStartTimes)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
			cell.separatorInset = UIEdgeInsets.zero
		}
		if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
			cell.preservesSuperviewLayoutMargins = false
		}
		if cell.responds(to: #selector(setter: UIView.layoutMargins)){
			cell.layoutMargins = UIEdgeInsets.zero
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let pad = CGFloat(15)
		let label = UILabel()
		// customize apperaance
		label.backgroundColor = Style.shared.whiteSmoke
		label.font = UIFont(name:SYSTEM_FONT, size: Style.shared.P15)
		switch section{
		case 0:
			label.text = "Customizing pillar order will separate your schedule from your school"
		default:
			label.text = " "
		}
		label.numberOfLines = 0
		label.frame = CGRect.init(x: pad, y: 0, width: self.tableView.frame.size.width - pad*2, height: self.tableView.frame.size.height)
		label.sizeToFit()
		label.frame = CGRect.init(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: label.frame.size.height + 20)
		return label
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let pad = CGFloat(15)
		let label = UILabel()
		// customize apperaance
		label.backgroundColor = Style.shared.whiteSmoke
		label.font = UIFont(name:SYSTEM_FONT, size: Style.shared.P15)
		switch section{
		case 0:
			label.text = "Customizing pillar order will separate your schedule from your school"
		default:
			label.text = " "
		}
		label.numberOfLines = 0
		label.frame = CGRect.init(x: pad, y: 0, width: self.tableView.frame.size.width - pad*2, height: self.tableView.frame.size.height)
		label.sizeToFit()
		label.frame = CGRect.init(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: label.frame.size.height + 20)
		return label.frame.size.height
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if(customizeOrder){
			return 2
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 88
		}
		return 44;
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return 7
		default:
			return 0
		}
	}
	
	func daySuffix(_ dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	
	func didPressSwitch(sender: UISwitch) {
		customizeOrder = sender.isOn
		self.tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if(indexPath.section == 0){
			ps.textLabel?.text = "Customize Order"
			ps.delegate = self
			return ps
		}
		
		let cell = UITableViewCell.init(style: .default, reuseIdentifier: "tableCell")
//		cell.textLabel?.text = "\(indexPath.row)"

		// date
		if(self.pillarStartTimes.count > indexPath.row){
			var GMTCalendar = Calendar.current
			GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
			let pillarDate:Date = Date.init(timeIntervalSince1970: Double(self.pillarStartTimes[indexPath.row]))
			let day = GMTCalendar.component(.day, from: pillarDate)
			let month = GMTCalendar.component(.month, from: pillarDate)
			let year = GMTCalendar.component(.year, from: pillarDate)
			cell.textLabel?.text = "\(month) \(day), \(year)"
		}

		
		return cell
	}

	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		if(pillarOrder.count > destinationIndexPath.row && pillarOrder.count > sourceIndexPath.row ){
			let movedObject = self.pillarOrder[sourceIndexPath.row]
			self.pillarOrder.remove(at: sourceIndexPath.row)
			self.pillarOrder.insert(movedObject, at: destinationIndexPath.row)
			NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) ")
			self.tableView.reloadData()
		}
	}

	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 1{
			return true
		}
		return false
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}

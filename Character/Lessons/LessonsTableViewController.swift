//
//  LessonsTableViewController.swift
//  Lessons
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

let monthAbbrevs = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]

class LessonsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
	
	var data: [Lesson]? {
		didSet{
			self.tableView.reloadData()
		}
	}
	var filteredLessons: [Lesson]? {
		didSet{
			self.tableView.reloadData()
		}
	}
	
	// SEARCH FUNCTION
	let searchController = UISearchController(searchResultsController: nil)
	
	func filterContentForSearchText(searchText: String, scope: String = "All") {
		filteredLessons = data?.filter { lesson in
			var didTitle = false
			var didBody = false
			var didTags = false
			if let title = lesson.title?.lowercased().contains(searchText.lowercased()){
				didTitle = title
			}
			if let body = lesson.body?.lowercased().contains(searchText.lowercased()){
				didBody = body
			}
			if let tags = lesson.tags?.lowercased().contains(searchText.lowercased()){
				didTags = tags
			}
			return didTitle || didBody || didTags
		}
		
		tableView.reloadData()
	}
	func updateSearchResultsForSearchController(searchController: UISearchController) {
//		let searchBar = searchController.searchBar
//		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//		filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
		filterContentForSearchText(searchText: searchController.searchBar.text!)
	}
	@available(iOS 8.0, *)
	func updateSearchResults(for searchController: UISearchController) {
//		let searchBar = searchController.searchBar
//		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//		filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
		filterContentForSearchText(searchText: searchController.searchBar.text!)
	}
	
	// FILTER GRADE LEVELS
	var showFilter:Bool = false
	var filteredData: [Lesson]?
	var filter:Int?{
		didSet{
			if(filter != nil){
				filteredData = filterLessons(filter!)
			}
			self.tableView.reloadData()
		}
	}
	func filterLessons(_ filterBy:Int) -> [Lesson] {
		var array:[Lesson] = []
		for lesson in data! {
			if lesson.grade == filterBy{
				array.append(lesson)
			}
		}
		return array
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.cellLayoutMarginsFollowReadableWidth = false;
		self.tableView.tableFooterView = UIView()
		
		self.title = "ALL LESSONS"
		
		// SEARCH
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		searchController.searchBar.tintColor = UIColor.white;

		self.extendedLayoutIncludesOpaqueBars = true
		
//		searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
//		searchController.searchBar.delegate = self

		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil);
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
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
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if(self.data != nil){
			return 1
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 200
		}
		return 120;
	}
	
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		if(showFilter && filter != nil){
//			return (self.filteredData?.count)!
//		}
//		if let d = self.data{
//			return d.count
//		}
//		return 0;
//	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.isActive && searchController.searchBar.text != "" {
			if let d = filteredLessons{
				return d.count
			}
		}
		if let d = self.data{
			return d.count
		}
		return 0
	}
	
	
	func daySuffix(_ dayOfMonth: Int) -> String {
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		
//		if(showFilter == false){
//			return nil
//		}
//		var viewH:CGFloat = 34
//		if(IS_IPAD){
//			viewH = 60
//		}
//		
//		let view = UIView()
//		view.backgroundColor = Style.shared.darkGray
//		
//		let buttonW = self.view.frame.size.width * 0.8
//		let button = UIButton()
//		button.backgroundColor = UIColor.clear
//		button.frame = CGRect(x: (self.view.frame.size.width - buttonW) * 0.5, y: 0, width: buttonW, height: viewH)
//		button.addTarget(self, action: #selector(filterButtonHandler), for: .touchUpInside)
//
//		let filterLabel = UILabel()
//		filterLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
//		filterLabel.textColor = Style.shared.whiteSmoke
//		filterLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.5 - 10, height: viewH)
//		filterLabel.textAlignment = .right
//		filterLabel.text = "Filter:"
//
//		let gradeLabel = UILabel()
//		gradeLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P15)
//		gradeLabel.textColor = UIColor.white
//		gradeLabel.frame = CGRect(x: self.view.frame.size.width*0.5, y: 0, width: self.view.frame.size.width*0.5, height: viewH)
//		gradeLabel.textAlignment = .left
//		if(filter == nil){
//			gradeLabel.text = "All Grades"
//		} else{
//			gradeLabel.text = Character.shared.gradeNames[filter!]
//		}
//		
//		view.addSubview(filterLabel)
//		view.addSubview(gradeLabel)
//		view.addSubview(button)
//		return view
//	}
//	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		if(showFilter == true){
//			if(IS_IPAD){
//				return 60
//			}
//			return 34
//		}
//		return 0
//	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = LessonsTableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		
		var objectForRow:Lesson
		// OLD FILTER
//		if(showFilter && filter != nil){
//			objectForRow = self.filteredData![(indexPath as NSIndexPath).row]
//		} else{
//			objectForRow = self.data![(indexPath as NSIndexPath).row]
//		}

		// NEW SEARCH FILTER
		objectForRow = self.data![(indexPath as NSIndexPath).row]
		if searchController.isActive && searchController.searchBar.text != "" {
			if let d = filteredLessons{
				objectForRow = d[(indexPath as NSIndexPath).row]
			}
		}

		var text:String = ""
		if let titleText = objectForRow.title{
			text = titleText
		}
		
		// date
		var date = Date()
		var GMTCalendar = Calendar.current
		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		if let objectDate = objectForRow.date{
			date = objectDate
		}
		let dateComponents:DateComponents = (GMTCalendar as NSCalendar).components([.month, .day], from: date as Date)

		// image
		if let imageFilename:String = objectForRow.image{
			Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, requiredDownload) in
				cell.imageView?.image = image
				if(requiredDownload){
					self.tableView.reloadData()
				}
			})
			// QUICK FIX for JPG / JPEG file name differences
			let filename: NSString = imageFilename as NSString
			let pathPrefix = filename.deletingPathExtension
			let alternateFileName = pathPrefix + ".jpeg"
			Cache.shared.imageFromStorageBucket(alternateFileName, completionHandler: { (image, didRequireDownload) in
				cell.imageView?.image = image
				if(didRequireDownload){
					self.tableView.reloadData()
				}
			})

		}

		if let gradeLevel = objectForRow.grade{
			cell.gradeLevel = gradeLevel
		}
		
		cell.titleText = text.uppercased()
		if let dateInt = dateComponents.day {
			let dayString = "\(dateInt)" + daySuffix(dateInt)
			let dateText: String = monthAbbrevs[dateComponents.month! - 1] + " " + dayString
			cell.dateText = dateText.uppercased()
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var nextObject:Lesson
		if(showFilter && filter != nil){
			nextObject = self.filteredData![(indexPath as NSIndexPath).row]
		} else{
			nextObject = self.data![(indexPath as NSIndexPath).row]
		}
		
		let vc: LessonTableViewController = LessonTableViewController()
		vc.data = nextObject
		vc.isLoadingLessons = false
//		let pillarName = nextObject["pillar"]!!
//		vc.title = String(pillarName).uppercaseString
//		vc.title = "TRUSTWORTHINESS"
//		vc.title = ""
//		if Character.shared.currentPillar != nil{
//			let currentPillar:Int = Character.shared.currentPillar!
//			if(currentPillar < Character.shared.pillarNames.count){
//				let currentPillarName = Character.shared.pillarNames[currentPillar]
//				vc.title = String(currentPillarName).uppercased()
//			}
//		}
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
	func filterButtonHandler(_ sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
		let action1 = UIAlertAction.init(title: Character.shared.gradeNames[0], style: .default) { (action) in
			self.filter = 0
		}
		let action2 = UIAlertAction.init(title: Character.shared.gradeNames[1], style: .default) { (action) in
			self.filter = 1
		}
		let action3 = UIAlertAction.init(title: Character.shared.gradeNames[2], style: .default) { (action) in
			self.filter = 2
		}
		let action4 = UIAlertAction.init(title: Character.shared.gradeNames[3], style: .default) { (action) in
			self.filter = 3
		}
		let action5 = UIAlertAction.init(title: "All Grades", style: .default) { (action) in
			self.filter = nil
		}
		let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		alert.addAction(action4)
		alert.addAction(action5)
		alert.addAction(cancel)

		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.present(alert, animated: true, completion: nil)
	}

}

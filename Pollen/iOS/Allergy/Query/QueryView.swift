//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol QueryViewDelegate{
	func queryViewDateDidChange(date:Date)
}

class QueryView: UIView, CategorySlideDelegate, SymptomPanelDelegate, DegreePanelDelegate, WelcomeViewProtocol{
	
	var delegate:QueryViewDelegate?
	
	let scrollView = MainScrollView()
	
	// welcome view
	let welcomeView = WelcomeToQueryView()
	
	// query view
	let dateLabel = UILabel()
	let topQuestionLabel = UILabel()
	let selectedCategoryTitle = UILabel()
	let categorySlideView = CategorySlideView()
	let symptomPanelView = SymptomPanelView()
	let degreePanelView = DegreePanelView()
	var selectedCategory:Int?
	var selectedSymptom:Int?
	var date:Date = Date()
	let dateNextButton = UIButton()
	let datePrevButton = UIButton()
	let queryDoneButton = UIButton()
	
	// visualize view
	let lineChartScrollView = UIScrollView()
	let chartViewBackButton = UIButton()
	let hrChartView = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
		self.updateColorsThroughout()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	func didSelectCategory(index: Int) {
		selectedCategory = index
		// show category title
		let categoryString = SymptomCategories[index]
		selectedCategoryTitle.text = categoryString.capitalized
		selectedCategoryTitle.isHidden = false
		// show symptom buttons
		symptomPanelView.showButtons()
		if let symptoms = SymptomNames[categoryString] {
			for i in 0..<symptoms.count{
				symptomPanelView.buttons[i].setTitle(symptoms[i], for: .normal)
			}
		}
		categorySlideView.selected = index
		updateColorsThroughout()
	}

	func didSelectSymptom(index: Int) {
		selectedSymptom = index

		guard let category = selectedCategory else { return }
		let categoryString = SymptomCategories[category]

		if BinaryCategories[categoryString]!{
			// set color of button
			guard let symptom = selectedSymptom else { return }
			guard let symptomArray = SymptomNames[categoryString] else { return }
			let symptomString = symptomArray[symptom]
//			if Allergies.shared.records
			if Allergies.shared.getRecord(date: self.date, category: categoryString, symptom: symptomString) != nil{
				Allergies.shared.updateRecord(date: self.date, category: categoryString, removeSymptom: symptomString)
			} else{
				Allergies.shared.updateRecord(date: self.date, category: categoryString, symptom: symptomString, degree: 1)
			}
			self.updateColorsThroughout()
		} else{
			// open degree panel
			degreePanelView.isHidden = false
		}
	}
	
	func didSelectDegree(sender: UIButton) {
		degreePanelView.isHidden = true

		guard let category = selectedCategory else { return }
		guard let symptom = selectedSymptom else { return }
//		categorySlideView.buttons[category].tintColor = colors[sender.tag]
		
		let degree = sender.tag
		let categoryString:String = SymptomCategories[category]
		guard let symptomArray = SymptomNames[categoryString] else { return }
		let symptomString = symptomArray[symptom]

		if(degree == -1){
			// remove entry
			Allergies.shared.updateRecord(date: self.date, category: categoryString, removeSymptom: symptomString)
		}else{
			Allergies.shared.updateRecord(date: self.date, category: categoryString, symptom: symptomString, degree: degree)
		}
		self.updateColorsThroughout()
	}
	
	func categoryViewDidChangePage(page:Int){
		formatQuestion()
	}

	func updateColorsThroughout(){
		let colors = [Style.shared.blue, Style.shared.colorNoPollen, Style.shared.colorMedium, Style.shared.colorVeryHeavy]
		
		for i in 0..<SymptomCategories.count{
			let categoryString = SymptomCategories[i]
			var color = Style.shared.colorNoEntry
			if let record = Allergies.shared.records[self.date.toString()]{
				if let categoryRecord = record.allergies[categoryString]{
					if let max = Array(categoryRecord.values).sorted().last{
						color = colors[max]
					}
				}
			}
			self.categorySlideView.categoryColors[i] = color
		}
		self.categorySlideView.setNeedsLayout()
		
		// presently selected ones
		//		self.symptomPanelView.symptomColors = [UIColor.black, UIColor.black, UIColor.black, UIColor.black]
		self.symptomPanelView.symptomColors = [Style.shared.colorNoEntry, Style.shared.colorNoEntry, Style.shared.colorNoEntry, Style.shared.colorNoEntry]
		guard let category = selectedCategory else { return }
		//		guard let symptom = selectedSymptom else { return }
		let categoryString = SymptomCategories[ category ]
		if let record = Allergies.shared.records[self.date.toString()]{
			if let categoryRecord = record.allergies[categoryString]{
				if let symptomsArray = SymptomNames[categoryString]{
					for i in 0..<symptomsArray.count{
						if let degree = categoryRecord[symptomsArray[i]]{
							self.symptomPanelView.symptomColors[i] = colors[degree]
						}
					}
				}
			}
		}
		self.symptomPanelView.setNeedsLayout()
	}

	func initUI(){
		
		categorySlideView.delegate = self
		symptomPanelView.delegate = self
		
		self.scrollView.isPagingEnabled = true
		self.scrollView.delaysContentTouches = false
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.isScrollEnabled = false

		dateLabel.textColor = UIColor.black
		dateLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
		dateNextButton.setTitleColor(UIColor.black, for: .normal)
		datePrevButton.setTitleColor(UIColor.black, for: .normal)
		dateNextButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		datePrevButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		dateNextButton.setTitle("▶︎", for: .normal)
		datePrevButton.setTitle("◀︎", for: .normal)
		dateNextButton.addTarget(self, action: #selector(dateNextButtonHandler), for: .touchUpInside)
		datePrevButton.addTarget(self, action: #selector(datePrevButtonHandler), for: .touchUpInside)
		topQuestionLabel.textColor = UIColor.gray
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		selectedCategoryTitle.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
		selectedCategoryTitle.textColor = UIColor.black
		selectedCategoryTitle.textAlignment = .center
		
		queryDoneButton.setTitle("Done", for: .normal)
		queryDoneButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		queryDoneButton.setTitleColor(UIColor.black, for: .normal)
		queryDoneButton.layer.borderColor = UIColor.black.cgColor
		queryDoneButton.layer.backgroundColor = UIColor.white.cgColor
		queryDoneButton.layer.cornerRadius = 20
		queryDoneButton.layer.borderWidth = 4
		queryDoneButton.sizeToFit()
		queryDoneButton.frame = CGRect(x: 0, y: 0, width: queryDoneButton.frame.size.width*2, height: queryDoneButton.frame.size.height*1.5)

		queryDoneButton.addTarget(self, action: #selector(doneButtonHandler), for: .touchUpInside)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDown)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetSelected), for: .touchDragEnter)

		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragOutside)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchCancel)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchDragExit)
		queryDoneButton.addTarget(self, action: #selector(doneButtonSetUnselected), for: .touchUpInside)

		self.addSubview(self.scrollView)
		self.scrollView.addSubview(dateLabel)
		self.scrollView.addSubview(datePrevButton)
		self.scrollView.addSubview(dateNextButton)
		self.scrollView.addSubview(topQuestionLabel)
		self.scrollView.addSubview(categorySlideView)
		self.scrollView.addSubview(selectedCategoryTitle)
		self.scrollView.addSubview(symptomPanelView)
		self.scrollView.addSubview(queryDoneButton)
		
		// welcome view
		welcomeView.delegate = self
		self.scrollView.addSubview(welcomeView)
		
		// chart views
		self.scrollView.addSubview(lineChartScrollView)
		
		self.didSelectCategory(index: 0)
	}
	
	func welcomeViewIntroScreen(){
		if UserDefaults.standard.bool(forKey: "welcomeScreenHasSeen") == true{
			self.scrollView.contentOffset = CGPoint(x: self.frame.size.width, y: 0)
		} else{
			self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
		}
	}
	
	func formatQuestion(){
		switch categorySlideView.currentCategoryPage{
		case 0:
			if Calendar.current.isDateInToday(self.date){
				topQuestionLabel.text = "What is bothering you today?"
			} else if Calendar.current.isDateInYesterday(self.date){
				topQuestionLabel.text = "What was bothering you yesterday?"
			} else if self.date.timeIntervalSinceNow < Date().timeIntervalSinceNow{
				// date in the past
				topQuestionLabel.text = "What was bothering you?"
			} else{
				// date in the future
				topQuestionLabel.text = "What will be bothering you?"
			}

		case 1:
			topQuestionLabel.text = "Exposures"

		case 2:
			if Calendar.current.isDateInToday(self.date){
				topQuestionLabel.text = "How are you feeling today?"
			} else if Calendar.current.isDateInYesterday(self.date){
				topQuestionLabel.text = "How were you feeling yesterday?"
			} else if self.date.timeIntervalSinceNow < Date().timeIntervalSinceNow{
				// date in the past
				topQuestionLabel.text = "How were you feeling?"
			} else{
				// date in the future
				topQuestionLabel.text = "How will you be feeling?"
			}
		default:
			topQuestionLabel.text = ""
		}
		
		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: self.frame.size.width + self.bounds.size.width*0.5, y: dateLabel.frame.origin.y + dateLabel.frame.size.height + topQuestionLabel.frame.size.height*0.5 + 10)

	}


	override func layoutSubviews() {
		super.layoutSubviews()

		let w:CGFloat = self.frame.size.width

		self.scrollView.frame = self.bounds
		self.scrollView.contentSize = CGSize(width: self.bounds.width*3, height: self.bounds.height)
		
		
		// welcome view
		welcomeViewIntroScreen()
		welcomeView.frame = self.bounds
		
		// chart views
		hrChartView.frame = CGRect(x: self.bounds.width*2 + 20, y: 40, width: self.bounds.width - 40, height: 4)
		hrChartView.backgroundColor = .black
		self.scrollView.addSubview(hrChartView)

		chartViewBackButton.setTitle("← My Allergies", for: .normal)
		chartViewBackButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		chartViewBackButton.setTitleColor(.black, for: .normal)
		chartViewBackButton.addTarget(self, action: #selector(chartViewBackButtonHandler), for: .touchUpInside)
		chartViewBackButton.sizeToFit()
		let ipadAdjust:CGFloat = IS_IPAD ? 12 : 0
		chartViewBackButton.frame = CGRect(x: self.bounds.width*2 + 20, y: 40 - chartViewBackButton.frame.size.height + ipadAdjust, width: chartViewBackButton.frame.size.width, height: chartViewBackButton.frame.size.height)
		self.scrollView.addSubview(chartViewBackButton)

		lineChartScrollView.frame = CGRect(x: self.bounds.width*2, y: 40, width: self.bounds.width, height: self.bounds.height - 40)
		
		
		// query views
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		dateLabel.text = dateFormatter.string(from: self.date)
		dateLabel.sizeToFit()
		dateLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.size.height*0.5)
		datePrevButton.sizeToFit()
		dateNextButton.sizeToFit()
		datePrevButton.center = CGPoint(x: dateLabel.center.x - dateLabel.frame.size.width*0.5-30, y: dateLabel.center.y)
		dateNextButton.center = CGPoint(x: dateLabel.center.x + dateLabel.frame.size.width*0.5+30, y: dateLabel.center.y)

		// set text of the question box
		formatQuestion()
		
		queryDoneButton.center = CGPoint(x: w + self.bounds.size.width*0.5, y: self.bounds.size.height - queryDoneButton.frame.size.height*0.5 - 20)

		let questionBottomY:CGFloat = topQuestionLabel.frame.origin.y + topQuestionLabel.frame.size.height
//		let questionFrame = CGRect(x: 0, y: yTop + 15, width: self.bounds.size.width, height: self.bounds.size.height - yTop - queryDoneButton.frame.size.height - 15 - 20 - 10)
		
		let bpPadW:CGFloat = w*0.025
		let bpPadH:CGFloat = w*0.025

		let slideH:CGFloat = self.bounds.width * 0.36
		categorySlideView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: slideH)
		categorySlideView.center = CGPoint(x: w + self.center.x, y: questionBottomY + slideH*0.5 + bpPadH*0.5)
		
		let categoryTitleH:CGFloat = Style.shared.P30 * 1.13
		selectedCategoryTitle.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: categoryTitleH)

		selectedCategoryTitle.center = CGPoint(x: w + self.bounds.size.width*0.5, y: categorySlideView.center.y + categorySlideView.frame.size.height*0.5 + selectedCategoryTitle.frame.size.height*0.5 + bpPadH)

		symptomPanelView.frame = CGRect(x: w + bpPadW, y: selectedCategoryTitle.frame.bottom + bpPadH, width: w - bpPadW*2, height: queryDoneButton.frame.origin.y - selectedCategoryTitle.frame.bottom - bpPadH*2)
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
			if degreePanelView.superview == nil {
				degreePanelView.isHidden = true
				degreePanelView.delegate = self
				appDelegate.rootViewController.view.addSubview(degreePanelView)
				degreePanelView.frame = appDelegate.rootViewController.view.bounds
			}
		}
	}
	
	@objc func dateNextButtonHandler(){
		var components = DateComponents()
		components.setValue(1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.delegate?.queryViewDateDidChange(date:self.date)
		self.setNeedsLayout()
		self.updateColorsThroughout()
	}
	
	@objc func datePrevButtonHandler(){
		var components = DateComponents()
		components.setValue(-1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.delegate?.queryViewDateDidChange(date:self.date)
		self.setNeedsLayout()
		self.updateColorsThroughout()
	}
	
	func doneButtonHandler(){
		generateCharts()
		self.scrollView.setContentOffset(CGPoint(x:self.bounds.size.width*2, y:0), animated: true)
	}
	
	func chartViewBackButtonHandler(){
		self.scrollView.setContentOffset(CGPoint(x:self.bounds.size.width, y:0), animated: true)
	}
	
	func doneButtonSetSelected(){
		self.queryDoneButton.layer.backgroundColor = UIColor.black.cgColor
		queryDoneButton.setTitleColor(UIColor.white, for: .normal)
	}
	func doneButtonSetUnselected(){
		self.queryDoneButton.layer.backgroundColor = UIColor.white.cgColor
		queryDoneButton.setTitleColor(UIColor.black, for: .normal)
	}
	
	func welcomeViewDoneButtonDidPress() {
		self.scrollView.scrollRectToVisible(CGRect(x:self.bounds.size.width, y:0, width:self.bounds.size.width, height:self.bounds.size.height), animated: true)
	}
	
	func generateCharts(){
		for subview in lineChartScrollView.subviews{
			subview.removeFromSuperview()
		}
		let chartData = Allergies.shared.chartData()
		print(chartData)
		
		var finalH:CGFloat = 0
		var i = 0
		for (symptomName,value) in chartData{
			let padH:CGFloat = self.bounds.size.width*0.2
			let padW:CGFloat = self.bounds.size.width*0.1
			let w = self.bounds.size.width - padW*2
			let h = self.bounds.size.width*0.35
			// label
			let label = UILabel()
			label.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
			label.textColor = .black
			label.text = symptomName
			label.sizeToFit()
			label.frame = CGRect(x: padW, y: padH*CGFloat(i+1) + h*CGFloat(i) - label.frame.size.height - 4, width: label.frame.size.width, height: label.frame.size.height)
			lineChartScrollView.addSubview(label)
			// chart
			let lineChartView = UILineChartView()
			lineChartView.values = value
			lineChartView.frame = CGRect(x: padW, y: padH*CGFloat(i+1) + h*CGFloat(i), width: w, height: h)
			finalH = lineChartView.frame.bottom
			lineChartScrollView.addSubview(lineChartView)
			i += 1
		}
		
//		var finalH:CGFloat = 0
//		for i in 0..<5{
//			let padH:CGFloat = self.bounds.size.width*0.2
//			let padW:CGFloat = self.bounds.size.width*0.1
//			let w = self.bounds.size.width - padW*2
//			let h = self.bounds.size.width*0.35
//			// label
//			let label = UILabel()
//			label.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
//			label.textColor = .black
//			label.text = SymptomCategories[i].capitalized
//			label.sizeToFit()
//			label.frame = CGRect(x: padW, y: padH*CGFloat(i+1) + h*CGFloat(i) - label.frame.size.height - 4, width: label.frame.size.width, height: label.frame.size.height)
//			lineChartScrollView.addSubview(label)
//			// chart
//			let lineChartView = UILineChartView()
//			lineChartView.frame = CGRect(x: padW, y: padH*CGFloat(i+1) + h*CGFloat(i), width: w, height: h)
//			finalH = lineChartView.frame.bottom
//			lineChartScrollView.addSubview(lineChartView)
//		}
		lineChartScrollView.contentSize = CGSize(width: lineChartScrollView.bounds.size.width, height: finalH + 30)
	}

}

//
//  QueryView.swift
//  Allergy
//
//  Created by Robby on 10/18/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class QueryView: UIView, CategorySlideDelegate, SymptomPanelDelegate, DegreePanelDelegate{
	
	let scrollView = MainScrollView()
	
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
		updateColorsThroughout()
	}

	func didSelectSymptom(index: Int) {
		selectedSymptom = index
		degreePanelView.isHidden = false
	}
	
	func updateColorsThroughout(){
		let colors = [Style.shared.blue, Style.shared.colorNoPollen, Style.shared.colorMedium, Style.shared.colorVeryHeavy]
		
		for i in 0..<SymptomCategories.count{
			let categoryString = SymptomCategories[i]
			var color = colors.first!
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
		self.symptomPanelView.symptomColors = [colors.first!,colors.first!,colors.first!,colors.first!]
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

	func didSelectDegree(sender: UIButton) {
		degreePanelView.isHidden = true

		guard let category = selectedCategory else { return }
		guard let symptom = selectedSymptom else { return }
//		categorySlideView.buttons[category].tintColor = colors[sender.tag]
		
		let degree = sender.tag
		if(degree == -1){
			return
		}
		let categoryString:String = SymptomCategories[category]
		guard let symptomArray = SymptomNames[categoryString] else { return }
		let symptomString = symptomArray[symptom]
		
		Allergies.shared.updateRecord(date: self.date, category: categoryString, symptom: symptomString, degree: degree)

		self.updateColorsThroughout()
	}
	
	func initUI(){
		
		categorySlideView.delegate = self
		symptomPanelView.delegate = self
		
		self.scrollView.isPagingEnabled = true
		self.scrollView.delaysContentTouches = false
		self.scrollView.showsHorizontalScrollIndicator = false
		
		dateLabel.textColor = Style.shared.blue
		dateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		dateNextButton.setTitleColor(Style.shared.blue, for: .normal)
		datePrevButton.setTitleColor(Style.shared.blue, for: .normal)
		dateNextButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		datePrevButton.titleLabel?.font = UIFont.systemFont(ofSize: Style.shared.P30)
		dateNextButton.setTitle("▶︎", for: .normal)
		datePrevButton.setTitle("◀︎", for: .normal)
		dateNextButton.addTarget(self, action: #selector(dateNextButtonHandler), for: .touchUpInside)
		datePrevButton.addTarget(self, action: #selector(datePrevButtonHandler), for: .touchUpInside)
		topQuestionLabel.textColor = Style.shared.blue
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P21)
		selectedCategoryTitle.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		selectedCategoryTitle.textColor = Style.shared.blue
		selectedCategoryTitle.textAlignment = .center

		queryDoneButton.setTitle("Done", for: .normal)
		queryDoneButton.titleLabel?.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		queryDoneButton.setTitleColor(Style.shared.blue, for: .normal)
		queryDoneButton.layer.borderColor = Style.shared.blue.cgColor
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
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let w:CGFloat = self.frame.size.width

		self.scrollView.frame = self.bounds
		self.scrollView.contentSize = CGSize(width: self.bounds.width*3, height: self.bounds.height)
		self.scrollView.contentOffset = CGPoint(x: w, y: 0)

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		dateLabel.text = dateFormatter.string(from: self.date)
		dateLabel.sizeToFit()
		dateLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.size.height*0.5)
		datePrevButton.sizeToFit()
		dateNextButton.sizeToFit()
		datePrevButton.center = CGPoint(x: dateLabel.center.x - dateLabel.frame.size.width*0.5-30, y: dateLabel.center.y)
		dateNextButton.center = CGPoint(x: dateLabel.center.x + dateLabel.frame.size.width*0.5+30, y: dateLabel.center.y)

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
		topQuestionLabel.sizeToFit()
		topQuestionLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.origin.y + dateLabel.frame.size.height + topQuestionLabel.frame.size.height*0.5 + 10)

		queryDoneButton.center = CGPoint(x: w + self.bounds.size.width*0.5, y: self.bounds.size.height - queryDoneButton.frame.size.height*0.5 - 20)

		let yTop:CGFloat = topQuestionLabel.frame.origin.y + topQuestionLabel.frame.size.height
		let questionFrame = CGRect(x: 0, y: yTop + 15, width: self.bounds.size.width, height: self.bounds.size.height - yTop - queryDoneButton.frame.size.height - 15 - 20 - 10)
		
//		let pad:CGFloat = 5.0
		let h:CGFloat = self.bounds.width * 0.23
		categorySlideView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: h)
		categorySlideView.center = CGPoint(x: w + self.center.x, y: questionFrame.origin.y + h*0.5)
		
		let categoryTitleH:CGFloat = Style.shared.P30 * 1.13
		selectedCategoryTitle.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: categoryTitleH)

		let bpPadW:CGFloat = w*0.05
		let bpPadH:CGFloat = w*0.05
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
		self.setNeedsLayout()
		self.updateColorsThroughout()
	}
	
	@objc func datePrevButtonHandler(){
		var components = DateComponents()
		components.setValue(-1, for: .day)
		if let newDate = Calendar.current.date(byAdding: components, to: self.date){
			self.date = newDate
		}
		self.setNeedsLayout()
		self.updateColorsThroughout()
	}
	
	func doneButtonHandler(){
		
	}
	
	func doneButtonSetSelected(){
		self.queryDoneButton.layer.backgroundColor = Style.shared.blue.cgColor
		queryDoneButton.setTitleColor(UIColor.white, for: .normal)
	}
	func doneButtonSetUnselected(){
		self.queryDoneButton.layer.backgroundColor = UIColor.white.cgColor
		queryDoneButton.setTitleColor(Style.shared.blue, for: .normal)
	}

}

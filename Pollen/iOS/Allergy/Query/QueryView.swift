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
	
	
	let panelTitles = [
		"eyes",
		"nose",
		"sinus",
		"throat"
	]

	let panelText = [
		["itchy", "red", "watery", "bags"],    // eyes
		["stuffy", "itchy", "runny", "blood"],  // nose
		["pressure", "pain", "colored discharge", "tooth pain"],  // sinus
		["clearing", "sore", "hoarse voice", "itchy / scratchy"]  // throat
	]

	let queryDoneButton = UIButton()

	override init(frame: CGRect) {
		super.init(frame: frame)
		initUI()
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
		selectedCategoryTitle.text = panelTitles[index].capitalized
		selectedCategoryTitle.isHidden = false
		// show symptom buttons
		symptomPanelView.showButtons()
		guard index < self.panelText.count else { return }
		let titles = self.panelText[index]
		for i in 0..<titles.count{
			symptomPanelView.buttons[i].setTitle(titles[i], for: .normal)
		}
	}
	
	func didSelectSymptom(index: Int) {
		if let category = selectedCategory{
//			self.categorySlideView.categoryHighlight[category] = !self.categorySlideView.categoryHighlight[category]
			self.categorySlideView.categoryHighlight[category] = true
			self.categorySlideView.setNeedsLayout()

//			symptomPanelView.buttons[index].setTitleColor(Style.shared.red, for: .normal)
//			symptomPanelView.buttons[index].layer.borderColor = Style.shared.red.cgColor
			degreePanelView.isHidden = false
		}
	}
	
	func didSelectDegree(sender: UIButton) {
		let colors = [Style.shared.blue, Style.shared.colorNoPollen, Style.shared.colorMedium, Style.shared.colorVeryHeavy]

		print(sender.tag)
		guard let category = selectedCategory else { return }
		categorySlideView.buttons[category].tintColor = colors[sender.tag]
		degreePanelView.isHidden = true
	}
	
	func initUI(){
		
		categorySlideView.delegate = self
		symptomPanelView.delegate = self
		
		self.scrollView.isPagingEnabled = true
		self.scrollView.delaysContentTouches = false
		self.scrollView.showsHorizontalScrollIndicator = false
		
		dateLabel.textColor = Style.shared.blue
		dateLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P30)
		topQuestionLabel.textColor = Style.shared.blue
		topQuestionLabel.font = UIFont(name: SYSTEM_FONT, size: Style.shared.P24)
		topQuestionLabel.text = "What is bothering you today?"
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
		dateLabel.text = dateFormatter.string(from: Date())
		dateLabel.sizeToFit()
		dateLabel.center = CGPoint(x: w + self.bounds.size.width*0.5, y: dateLabel.frame.size.height*0.5)

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

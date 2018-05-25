//
//  PollenCountViewController.swift
//  Allergy
//
//  Created by Robby on 4/12/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class PollenCountViewController: UITableViewController {
	
	var data:PollenSamples?{
		didSet{
			self.tableView.reloadData()
			if let d = data{
				if let date = d.date{
					self.title = Style.shared.dayStringForDate(date).uppercased()
					self.drawBackgroundLayer()
				}
			}
		}
	}
	
	let labelImageView = UIImageView()
	
	let gridView = UIView()
	let gridLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
				
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
		self.navigationItem.rightBarButtonItem = newBackButton

		let font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18) ?? UIFont.boldSystemFont(ofSize: Style.shared.P18)
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: Style.shared.blue], for:.normal)

		self.tableView.separatorStyle = .none
		
		gridView.backgroundColor = .clear
		gridView.frame = self.view.bounds
		self.view.addSubview(gridView)
		gridView.layer.insertSublayer(gridLayer, at: 0)

		drawBackgroundLayer()
	}
	
	func drawBackgroundLayer(){
		// remove all views if drawing more than once
		for view in self.gridView.subviews{ view.removeFromSuperview() }
		gridLayer.sublayers = []

		let lineFrame:CGFloat = self.view.frame.size.width * 0.5
		let strokeWeight:CGFloat = 38
		let pad:CGFloat = 10
		
//		let sampleData = [.low, .medium, .heavy, .veryHeavy].map { PollenSample(withKey: "cot", value: Pollen.shared.getValueFor(key: "cot", atRating: $0)) }
		
		let sampleData:[[String:Any]] = [
			["name" : Rating.low.description(), "logValue" : 0.177],
			["name" : Rating.medium.description(), "logValue" : 0.328],
			["name" : Rating.heavy.description(), "logValue" : 0.588],
			["name" : Rating.veryHeavy.description(), "logValue" : 1.0]
		]
		// draw sideways text marking low, medium, heavy, very heavy lines
		let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		let context = UIGraphicsGetCurrentContext()!
		context.translateBy (x: size.width / 2, y: size.height / 2)
		context.scaleBy (x: 1, y: -1)
		for sample in sampleData{
			let font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30) ?? UIFont.boldSystemFont(ofSize: Style.shared.P30)
			let attributes = [NSAttributedStringKey.foregroundColor: Style.shared.lightGray,
							  NSAttributedStringKey.font: font]
			context.saveGState()
			// Undo the inversion of the Y-axis (or the text goes backwards!)
			context.scaleBy(x: 1, y: -1)
			context.rotate(by: CGFloat.pi / 2.0)
			let str:String = sample["name"] as! String
			let offset = str.size(withAttributes: attributes)
			let ratingPoint:CGPoint = CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(sample["logValue"] as! Float), y: 0.0)
			context.translateBy(x: -offset.width + size.width*0.33, y: size.width*0.5 - ratingPoint.x - offset.height*0.85)
			str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
			context.restoreGState()
		}
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		labelImageView.image = image
		labelImageView.frame = CGRect(x: 0, y: self.view.frame.size.height - size.height, width: size.width, height: size.height)
		self.gridView.addSubview(labelImageView)

		for sample in sampleData{
			let shape = CAShapeLayer()
			let bz = UIBezierPath()
			bz.move(to: CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(sample["logValue"] as! Float), y: 0.0))
			bz.addLine(to: CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(sample["logValue"] as! Float), y: self.view.frame.size.height))
			shape.lineWidth = 4
			let lineDashPatterns: [NSNumber]  = [0, 8]
			shape.lineDashPattern = lineDashPatterns
			shape.lineCap = kCALineCapRound
			shape.strokeColor = Style.shared.athensGray.cgColor
			shape.path = bz.cgPath
			gridLayer.addSublayer(shape)
		}
	}
	
	override func viewDidLayoutSubviews() {
		self.view.sendSubview(toBack: self.labelImageView)
		self.view.sendSubview(toBack: self.gridView)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		self.navigationController?.navigationBar.barStyle = .default
//		self.setNeedsStatusBarAppearanceUpdate()
//		self.navigationController?.setNeedsStatusBarAppearanceUpdate()
//		setNeedsStatusBarAppearanceUpdate()
//
	}
	
//	override var preferredStatusBarStyle: UIStatusBarStyle {
//		return .lightContent
//	}

	@objc func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 68
		}
		return 44
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
		return data != nil ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data != nil ? data!.relevantSamples().count : 0
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = LineTableViewCell.init(style: .default, reuseIdentifier: "BarTableViewCell")
		cell.selectionStyle = .none
		cell.data = self.data!.relevantSamples().sorted(by:{return $0.logValue > $1.logValue;})[indexPath.row]
        return cell
    }

}

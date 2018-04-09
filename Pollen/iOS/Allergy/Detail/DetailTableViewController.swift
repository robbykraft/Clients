//
//  DailyTableViewController.swift
//  Allergy
//
//  Created by Robby on 4/12/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
	
	var data:Sample?{
		didSet{
			self.tableView.reloadData()
			if let d = data{
				self.report = d.report().sorted(by: { (a1, a2) -> Bool in
					return a1.2 > a2.2
				})
				if let date = d.date{
					self.title = Style.shared.dayStringForDate(date).uppercased()
				}
			}
		}
	}
	
	let labelImageView = UIImageView()

	var report:[(String, Int, Float, Rating)]? // name, value, 0.0-1.0 value, Rating
	
	let gridView = UIView()
	let gridLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
				
		let newBackButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
		self.navigationItem.rightBarButtonItem = newBackButton

		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)

		self.tableView.separatorStyle = .none
		
		let lineFrame:CGFloat = self.view.frame.size.width * 0.5
		let strokeWeight:CGFloat = 38
		let pad:CGFloat = 10
		gridView.backgroundColor = .clear
		gridLayer.sublayers = []
		gridView.frame = self.view.bounds
//		gridView.frame = CGRect(x: self.view.bounds.size.width*0.5, y: self.view.bounds.size.height*0.5, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
//		gridView.backgroundColor = .purple
		self.view.addSubview(gridView)
		self.gridView.layer.insertSublayer(gridLayer, at: 0)

		let ratingArray:[Rating] = [.low, .medium, .heavy, .veryHeavy]
		
		for rating in ratingArray{
			let logValue = Pollen.shared.logValueFor(key: "cot", value: Pollen.shared.getValueFor(key: "cot", atRating: rating))
			let shape = CAShapeLayer()
			let bz = UIBezierPath()
			bz.move(to: CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(logValue), y: 0.0))
			bz.addLine(to: CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(logValue), y: self.view.frame.size.height))
			shape.lineWidth = 4
			let lineDashPatterns: [NSNumber]  = [0, 8]
			shape.lineDashPattern = lineDashPatterns
			shape.lineCap = kCALineCapRound
			shape.strokeColor = Style.shared.athensGray.cgColor
			shape.path = bz.cgPath
			gridLayer.addSublayer(shape)
		}
		
		let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//		UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
		let context = UIGraphicsGetCurrentContext()!
		context.translateBy (x: size.width / 2, y: size.height / 2)
		context.scaleBy (x: 1, y: -1)

		for rating in ratingArray{
			
			// Set the text attributes
			let attributes = [NSForegroundColorAttributeName: Style.shared.lightGray,
			                  NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)]
			// Save the context
			context.saveGState()
			// Undo the inversion of the Y-axis (or the text goes backwards!)
			context.scaleBy(x: 1, y: -1)
			// Move the origin to the centre of the text (negating the y-axis manually)
//			context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
			// Rotate the coordinate system
			context.rotate(by: CGFloat.pi / 2.0)
			// Calculate the width of the text
			let str = Pollen.shared.stringForRating(rating)
			let offset = str.size(attributes: attributes)
			// Move the origin by half the size of the text

			let logValue = Pollen.shared.logValueFor(key: "cot", value: Pollen.shared.getValueFor(key: "cot", atRating: rating))
			let ratingPoint:CGPoint = CGPoint.init(x: 1+strokeWeight+pad + lineFrame*CGFloat(logValue), y: 0.0)
			context.translateBy(x: -offset.width + size.width*0.33, y: size.width*0.5 - ratingPoint.x - offset.height*0.85)
			// Draw the text
			str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
			// Restore the context
			context.restoreGState()
		}
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		labelImageView.image = image
//		labelImageView.backgroundColor = UIColor.purple
		labelImageView.frame = CGRect(x: 0, y: self.view.frame.size.height - size.height, width: size.width, height: size.height)
		self.view.addSubview(labelImageView)
		
		// Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

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
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}

	func doneButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if(IS_IPAD){
			return 68
		}
		return 44
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		if self.report != nil{
			return 1
		}
		return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if let r = self.report{
			return r.count
		}
		return 0
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		let cell = LineTableViewCell.init(style: .default, reuseIdentifier: "BarTableViewCell")
		cell.selectionStyle = .none
		if let r = report{
			if r.count > indexPath.row{
				let (name, value, logValue, rating) = r[indexPath.row]
				cell.textLabel?.text = name
				cell.data = (value, logValue)
				cell.rating = rating
			}
		}
		
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

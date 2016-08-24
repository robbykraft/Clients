//
//  LessonTableViewController.swift
//  Lessons
//
//  Created by Robby on 8/12/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class LessonTableViewController: UITableViewController {

	var data: Lesson?{
		didSet{
			self.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = Style.shared.whiteSmoke
		self.tableView.backgroundColor = Style.shared.whiteSmoke
		self.tableView.separatorColor = UIColor.clearColor();
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if(data == nil){
			return 0
		}
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(data != nil){
			return 3
		}
		return 0
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 180
	}

	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
		switch indexPath.row {
		case 0:
			let vc: LessonViewController = LessonViewController()
			vc.data = self.data
			vc.title = "DAILY LESSON"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 1:
			let vc: QuoteViewController = QuoteViewController()
			vc.data = self.data
			vc.title = "DAILY QUOTE"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		case 2:
			let vc: ChallengesViewController = ChallengesViewController()
			vc.data = self.data
			vc.title = "DAILY CHALLENGE"
			self.navigationController?.pushViewController(vc, animated: true)
			break
		default:
			break
		}
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			return lessonCellWithData(data)
		case 1:
			return quoteCellWithData(data)
		case 2:
			return challengesCellWithData(data)
		default:
			return UITableViewCell()
		}
    }
	
	func lessonCellWithData(data:Lesson?) -> LessonTableViewCell {
		let cell = LessonTableViewCell()
		cell.title = data?.title?.uppercaseString
		let imageFilename:String = (data?.image!)!
		Cache.shared.imageFromStorageBucket(imageFilename, completionHandler: { (image, requiredDownload) in
			cell.imageView?.image = image
			if(requiredDownload){
				self.tableView.reloadData()
			}
		})
		return cell
	}
	
	func quoteCellWithData(data:Lesson?) -> QuoteTableViewCell {
		let cell = QuoteTableViewCell()
		cell.textLabel?.text = data?.quote!
		return cell
	}

	func challengesCellWithData(data:Lesson?) -> ChallengesTableViewCell {
		let cell = ChallengesTableViewCell()
		return cell
	}
	
}

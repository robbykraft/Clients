//
//  MasterNavigationController.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class MasterController: UITabBarController {
	
	let allLessonsVC = LessonsTableViewController()
	let todayLessonVC = LessonTableViewController()
	let moreVC = MoreViewController()

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		// calling init() calls this function
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initCustom()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initCustom()
	}
	
	func initCustom(){
		
		let tab1NavController = UINavigationController()
		let tab2NavController = UINavigationController()
		let tab3NavController = UINavigationController()
	
		tab1NavController.setViewControllers([allLessonsVC], animated:false)
		tab2NavController.setViewControllers([todayLessonVC], animated:false)
		tab3NavController.setViewControllers([moreVC], animated:false)
		
		self.viewControllers = [tab1NavController, tab2NavController, tab3NavController]

		tab1NavController.tabBarItem = UITabBarItem.init(title: "ALL LESSONS", image: nil, selectedImage: nil)
		tab2NavController.tabBarItem = UITabBarItem.init(title: nil, image: dateImageCircle(), selectedImage: nil)
		tab3NavController.tabBarItem = UITabBarItem.init(title: "MORE...", image: nil, selectedImage: nil)
		
		tab1NavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -14)
		tab2NavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -14)
		tab3NavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -14)
		
		self.selectedIndex = 1
		
		Character.shared.loadLessons { (lessons) in
			if(lessons == nil){
				// problem connecting to the database
			}
			else{
				Fire.shared.getUser { (uid, userData) in
					if(uid != nil && userData != nil){
						if(userData!["grade"] == nil){
							// user hasn't been updated with a Grade Level
							let gradeLevels:[Int] = [0,1,2,3]
							self.reloadLessons(gradeLevels)
						}
						else{
							let gradeLevels:[Int] = userData!["grade"] as! [Int]
							self.reloadLessons(gradeLevels)
						}
					}
				}
			}
		}
	}
	
	func reloadLessons(gradeLevels:[Int]){
		let lessons:Array? = Character.shared.lessonsArray([0], gradeLevels: gradeLevels)
		if(lessons != nil){
			self.allLessonsVC.data = lessons
			self.todayLessonVC.data = lessons![0]
			if(gradeLevels == [0,1,2,3]){
				self.allLessonsVC.showFilter = true
			} else{
				self.allLessonsVC.showFilter = false
			}
			
			let todaysPillar:Int = lessons![0].pillar!
			self.todayLessonVC.navigationItem.title = Character.shared.pillarNames[todaysPillar].uppercaseString
		}
	}

	
	func dateImageCircle() -> UIImage{
		let size:CGSize = CGSizeMake(72, 72)
		let dateDay:NSDateComponents = NSCalendar.currentCalendar().components(.Day, fromDate: NSDate())
		
		let numberLabel = UILabel()
		numberLabel.text = "\(dateDay.day)"
		numberLabel.font = UIFont(name: SYSTEM_FONT, size: 36)!
		numberLabel.textColor = Style.shared.lightBlue
		numberLabel.sizeToFit()
		
		let todayLabel = UILabel()
		todayLabel.text = "Today"
		todayLabel.font = UIFont(name: SYSTEM_FONT, size: 16)!
		todayLabel.textColor = Style.shared.lightBlue
		todayLabel.sizeToFit()
		
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
		let context = UIGraphicsGetCurrentContext()
		
		UIColor.whiteColor().setFill()
		Style.shared.lightBlue.setStroke()
		CGContextFillEllipseInRect(context, CGRectMake(2, 2, size.width - 4, size.height - 4))
		CGContextStrokeEllipseInRect(context, CGRectMake(2, 2, size.width - 4, size.height - 4))
		
		Style.shared.lightBlue.setFill()
		
		CGContextSaveGState(context);
		CGContextTranslateCTM(context,
		                      size.width*0.5 - numberLabel.frame.size.width*0.5,
		                      size.height*0.36 - numberLabel.frame.size.height*0.5)
		numberLabel.layer.drawInContext(context!)
		CGContextRestoreGState(context)
		
		CGContextSaveGState(context);
		CGContextTranslateCTM(context,
		                      size.width*0.5 - todayLabel.frame.size.width*0.5,
		                      size.height*0.66 - todayLabel.frame.size.height*0.5)
		todayLabel.layer.drawInContext(context!)
		CGContextRestoreGState(context)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image.imageWithRenderingMode(.AlwaysOriginal)
	}
}

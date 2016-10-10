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

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
		
		loadDataAppWide()
	}
	
	func loadDataAppWide() {
		Fire.shared.getUser { (uid, userData) in
			if(uid != nil && userData != nil){
				var gradeLevels:[Int]
				if(userData!["grade"] == nil){
					// user hasn't been updated with a Grade Level
					gradeLevels = [0,1,2,3]
				}
				else{
					gradeLevels = userData!["grade"] as! [Int]
				}
//				self.reloadLessons(gradeLevels)
				Character.shared.downloadAndPrepareLessons({ (success) in
					self.setLoadingScreen(visible: true)
					self.reloadLessons(gradeLevels)
				})
			}
		}
	}
	
	func setLoadingScreen(visible:Bool){
		if(visible){
			self.todayLessonVC.isLoadingLessons = true
		} else{
			self.todayLessonVC.isLoadingLessons = false
		}
	}

	func reloadLessons(_ gradeLevels:[Int]){
		let (todaysLesson, lessonArray) = Character.shared.lessonsWithFilter(gradeLevels)
		
		if(lessonArray.count > 0){
			self.allLessonsVC.data = lessonArray
			if(gradeLevels == [0,1,2,3]){
				self.allLessonsVC.showFilter = true
			} else{
				self.allLessonsVC.showFilter = false
			}
		}
		if(todaysLesson != nil){
			self.todayLessonVC.data = todaysLesson
			let todaysPillar:Int = todaysLesson!.pillar!
			self.todayLessonVC.navigationItem.title = Character.shared.pillarNames[todaysPillar].uppercased()
		}
		self.setLoadingScreen(visible: false)
	}

	
	func dateImageCircle() -> UIImage{
		let size:CGSize = CGSize(width: 72, height: 72)
		let dateDay:DateComponents = (Calendar.current as NSCalendar).components(.day, from: Date())
		
		let numberLabel = UILabel()
		if let dayInt = dateDay.day {
			numberLabel.text = "\(dayInt)"
		}
		numberLabel.font = UIFont(name: SYSTEM_FONT, size: 36)!
		numberLabel.textColor = Style.shared.lightBlue
		numberLabel.sizeToFit()
		
		let todayLabel = UILabel()
		todayLabel.text = "Today"
		todayLabel.font = UIFont(name: SYSTEM_FONT, size: 16)!
		todayLabel.textColor = Style.shared.lightBlue
		todayLabel.sizeToFit()
		
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()
		
		UIColor.white.setFill()
		Style.shared.lightBlue.setStroke()
		context?.fillEllipse(in: CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4))
		context?.strokeEllipse(in: CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4))
		
		Style.shared.lightBlue.setFill()
		
		context?.saveGState();
		context?.translateBy(x: size.width*0.5 - numberLabel.frame.size.width*0.5,
		                      y: size.height*0.36 - numberLabel.frame.size.height*0.5)
		numberLabel.layer.draw(in: context!)
		context?.restoreGState()
		
		context?.saveGState();
		context?.translateBy(x: size.width*0.5 - todayLabel.frame.size.width*0.5,
		                      y: size.height*0.66 - todayLabel.frame.size.height*0.5)
		todayLabel.layer.draw(in: context!)
		context?.restoreGState()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!.withRenderingMode(.alwaysOriginal)
	}
}

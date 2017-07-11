//
//  MasterNavigationController.swift
//  Voila
//
//  Created by Robby on 7/5/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//


import UIKit
import Firebase

class MasterNavigationController: UINavigationController {
	
	let projectsVC = ProjectsViewController()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		// calling init() calls this function
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initCustom()
	}
	override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
		super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
		initCustom()
	}
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
		initCustom()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initCustom()
	}
	
	func initCustom(){
		self.viewControllers = [self.projectsVC]
	}
}

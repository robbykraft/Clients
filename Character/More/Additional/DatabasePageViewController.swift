//
//  DatabasePageViewController.swift
//  Character
//
//  Created by Robby on 8/28/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class DatabasePageViewController: UIViewController {
	
	let textView = UITextView()
	
	var databasePath:String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
		
		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 20, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 18)
		textView.backgroundColor = Style.shared.whiteSmoke
		self.view.addSubview(textView)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
		let statusHeight:CGFloat = statusBarHeight()
		textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navBarHeight - tabBarHeight - statusHeight)
		if(databasePath != nil){
			Fire.shared.loadData(databasePath) { (data) in
				self.textView.text = data as! String
			}
		}
	}
}

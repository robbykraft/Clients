//
//  PillarViewController.swift
//  Character
//
//  Created by Robby on 8/24/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class PillarViewController: UIViewController {

	let textView = UITextView()
	
	var pillarNumber:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 20, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 18)
		textView.backgroundColor = Style.shared.whiteSmoke
		self.view.addSubview(textView)
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil);
    }
	
	override func viewWillAppear(animated: Bool) {
		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let tabBarHeight:CGFloat = self.tabBarController!.tabBar.frame.size.height;
		let statusHeight:CGFloat = statusBarHeight()
		textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navBarHeight - tabBarHeight - statusHeight)
		
		var tag = 0
		if(pillarNumber != nil){
			tag = pillarNumber!
		}

		self.title = Character.shared.pillarNames[tag].uppercaseString

		Fire.shared.loadData("evergreen/pillars/\(tag)") { (data) in
			self.textView.text = data as! String
		}
	}

}

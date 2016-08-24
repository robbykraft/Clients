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
		self.view.addSubview(textView)
		textView.textContainerInset = UIEdgeInsetsMake(20, 8, 0, 8)
		textView.font = UIFont(name: SYSTEM_FONT, size: 15)

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(animated: Bool) {
		textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
		
		var tag = 0
		if(pillarNumber != nil){
			tag = pillarNumber!
		}
		
		Fire.shared.loadData("evergreen/pillars/\(tag)") { (data) in
			self.textView.text = data as! String
		}
	}

}

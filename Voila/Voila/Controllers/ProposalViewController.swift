//
//  ProposalViewController.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import MessageUI

class ProposalViewController: UIViewController, MFMailComposeViewControllerDelegate {

	let projectTitle = UILabel()
	let scrollView = UIScrollView()
	let roomLabels:[UILabel] = []
	let roomFields:[UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let sendButton = UIBarButtonItem.init(title: "Email", style: .done, target: self, action: #selector(sendProposal))
		self.navigationItem.rightBarButtonItem = sendButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)

        // Do any additional setup after loading the view.
		self.scrollView.frame = self.view.bounds
		self.view.addSubview(self.scrollView)
		buildPage()
    }
	
	func buildPage(){
		if let project = Voila.shared.project{
			self.projectTitle.text = project.name
			self.projectTitle.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P30)
			self.scrollView.addSubview(self.projectTitle)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.projectTitle.sizeToFit()

	}

	
	func sendProposal(){
		Voila.shared.sendProposal(self)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
}

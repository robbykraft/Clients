//
//  ProposalViewController.swift
//  Voila
//
//  Created by Robby on 8/23/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class ProposalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let sendButton = UIBarButtonItem.init(title: "Send", style: .done, target: self, action: #selector(sendProposal))
		self.navigationItem.rightBarButtonItem = sendButton
		self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT_B, size: Style.shared.P18)!, NSForegroundColorAttributeName: Style.shared.blue], for:.normal)

		let webView:UIWebView = UIWebView()
		webView.loadHTMLString(Voila.shared.htmlProposal(), baseURL: nil)
		self.view = webView

        // Do any additional setup after loading the view.
    }
	
	func sendProposal(){
		if let project = Voila.shared.project{
			if project.email != nil && project.email! != ""{
				
			} else{
				let alert = UIAlertController(title: "Email Missing", message: "Enter client's email in 'Project Details'", preferredStyle: .alert)
				let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
				alert.addAction(action1)
				self.present(alert, animated: true, completion: nil)
			}
		}
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

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

	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self
		mailComposerVC.setToRecipients(["someone@somewhere.com"])
		mailComposerVC.setSubject("Voila Proposal")
		mailComposerVC.setMessageBody(Voila.shared.htmlProposal(), isHTML: true)
		return mailComposerVC
	}
	
	func sendProposal(){
		if let project = Voila.shared.project{
			print("project.email")
			print(project.email)
			
			let mailComposeViewController = configuredMailComposeViewController()
			if MFMailComposeViewController.canSendMail() {
				self.present(mailComposeViewController, animated: true, completion: nil)
			} else {
				//			self.showSendMailErrorAlert()
			}

			
//			if project.email != nil && project.email! != ""{

//				let emailString = project.email!

//				print("MFMailComposeViewController")
//				let mc:MFMailComposeViewController = MFMailComposeViewController()
//				mc.mailComposeDelegate = self
//				mc.setSubject("Voila Proposal")
//				mc.setMessageBody(Voila.shared.htmlProposal(), isHTML: true)
//				mc.setToRecipients(["robby@robbykraft.com"])
//				mc.setToRecipients([emailString])
//				print(mc);
//				self.present(mc, animated: true, completion: nil)

				
//			} else{
//				let alert = UIAlertController(title: "Email Missing", message: "Enter client's email in 'Project Details'", preferredStyle: .alert)
//				let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
//				alert.addAction(action1)
//				self.present(alert, animated: true, completion: nil)
//			}
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

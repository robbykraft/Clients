//
//  ProposalMaker.swift
//  Voila
//
//  Created by Robby on 4/9/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

// todo remove this
import WebKit

class ProposalMaker{
	
	static let shared = ProposalMaker()

	func mailDidFinish(_ result: MFMailComposeResult){
		switch result{
		case .sent:
			print("sent")
			if let project = Voila.shared.project{
				project.proposalSent = Int(Date().timeIntervalSince1970)
				project.synchronize(completionHandler:nil)
				Fire.shared.addData(project.databaseForm(), asChildAt: "proposals", completionHandler: { (success, newKey, ref) in
				});
			}
//			UIScreen.navigationController.popToRootViewController()
		case .saved: print("saved")
		case .failed: print("failed")
		case .cancelled: print("canceled")
		}
	}
	
	func messageDidFinish(_ result: MessageComposeResult) {
		switch result {
		case .sent:
			if let project = Voila.shared.project{
				project.proposalSent = Int(Date().timeIntervalSince1970)
				project.synchronize(completionHandler:nil)
				Fire.shared.addData(project.databaseForm(), asChildAt: "proposals", completionHandler: { (success, newKey, ref) in
				});
			}
		case .failed: break
		case .cancelled: break
		}
	}
	
	func sendMMSProposal(_ viewController:UIViewController) {
		guard let project = Voila.shared.project else { return }
		
		if project.email != nil && project.email! != "" {
//			project.proposalSent = Int(Date().timeIntervalSince1970)
			// added to confirm database
			if !MFMailComposeViewController.canSendMail() {
				let alert = UIAlertController(title: "Email", message: "This app uses your iOS email account. Setup email in your iOS settings.", preferredStyle: .alert)
				let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
				alert.addAction(action1)
				viewController.present(alert, animated: true, completion: nil)
				return;
			}
//			let sendEmail = project.email!
			
			let messageController = MFMessageComposeViewController()
			messageController.messageComposeDelegate = viewController as? MFMessageComposeViewControllerDelegate
			
			if let pdfData = PDFMaker.shared.pdfProposal(project:project, confirmKey:"") {
//				mailComposerVC.addAttachmentData(pdfData as Data, mimeType: "application/pdf", fileName: "invoice.pdf")
				messageController.addAttachmentData(pdfData as Data, typeIdentifier: "public.composite-content", filename: "proposal.pdf")
			}
			viewController.present(messageController, animated: true, completion: nil)
		}
	}
	
	func sendEmailProposal(_ viewController:UIViewController) {
		
		if let project = Voila.shared.project{
			if project.email != nil && project.email! != "" {
				//				project.proposalSent = Int(Date().timeIntervalSince1970)
				// added to confirm database
				if !MFMailComposeViewController.canSendMail() {
					let alert = UIAlertController(title: "Email", message: "This app uses your iOS email account. Setup email in your iOS settings.", preferredStyle: .alert)
					let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
					alert.addAction(action1)
					viewController.present(alert, animated: true, completion: nil)
					return;
				}
				let sendEmail = project.email!
				
				let mailComposerVC = MFMailComposeViewController()
				mailComposerVC.mailComposeDelegate = viewController as? MFMailComposeViewControllerDelegate
				mailComposerVC.setToRecipients([sendEmail])
				mailComposerVC.setSubject(project.name + " - Voila Design Home - Staging Proposal")
				mailComposerVC.setMessageBody(HTMLProposal.makeProposal(project:project, confirmKey:""), isHTML: true)
				if let pdfData = PDFMaker.shared.pdfProposal(project:project, confirmKey:"") {
					mailComposerVC.addAttachmentData(pdfData as Data, mimeType: "application/pdf", fileName: "invoice.pdf")
				}
				viewController.present(mailComposerVC, animated: true, completion: nil)
			} else{
				let alert = UIAlertController(title: "Email Missing", message: "Enter client's email in 'Project Details'", preferredStyle: .alert)
				let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
				alert.addAction(action1)
				viewController.present(alert, animated: true, completion: nil)
			}
		}
	}
	
}

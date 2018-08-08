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
		case .saved:
			print("saved")
		case .failed:
			print("failed")
		case .cancelled:
			print("canceled")
		}
	}
	
	func sendProposal(_ viewController:UIViewController){
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
                mailComposerVC.setMessageBody(htmlProposal(project:project, confirmKey:""), isHTML: true)
				viewController.present(mailComposerVC, animated: true, completion: nil)
			} else{
				let alert = UIAlertController(title: "Email Missing", message: "Enter client's email in 'Project Details'", preferredStyle: .alert)
				let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
				alert.addAction(action1)
				viewController.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	func htmlProposal(project:Project, confirmKey:String)->String{
//        print(pageHeader + self.titleForProject(project) + self.tableForProject(project) + self.tableOfCostsForProject(project) + termsAndConditionsText + firebaseButton(key: confirmKey) + pageFooter)
        return pageHeaderWithTitle(project.name) + self.tableForProject(project) + self.tableOfCostsForProject(project) + pageFooter
	}
	
	func tableOfCostsForProject(_ project:Project)->String{
		var table = ""
		
		let total:Int = project.cost()
		var discountTotal:Int = 0
		var discountPct:Int = 0
		var discountText:String = ""
		var taxPct:Float = 0.0
		var taxTotal:Int = 0
		var renewalsTotal:Int = 0
		
		if let a = project.discountTotal { discountTotal = a }
		if let a = project.discountPct { discountPct = a }
		if let a = project.discountText { discountText = a }
		if let a = project.taxPct { taxPct = a }
		if let a = project.taxTotal { taxTotal = a }
		if let a = project.renewalsTotal { renewalsTotal = a }
		
		let totalAfterDiscount = total - discountTotal
		let grandTotal:Int = totalAfterDiscount + taxTotal
		
		let discountTotalRounded = Int(round(Float(discountTotal)))
		let totalAfterDiscountRounded:Int = Int(round(Float(totalAfterDiscount)))
		let taxTotalRounded:Int = Int(round(Float(taxTotal)))
		let grandTotalRounded:Int = Int(round(Float(grandTotal)))
		let renewalsTotalRounded:Int = Int(round(Float(renewalsTotal)))
        
        table.append("<br><br><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"min-width:480px;max-width:540px;height:2px;background-color:#333333;margin:auto\"></div></div><br><table style=\"margin:auto;width:50%;min-width:20em;\">")

        if discountTotal != 0{
            table.append("<tr><td>Total Before Discount</td><td></td><td style=\"text-align:right;\">$\(total)</td></tr><tr><td></td><td></td><td></td></tr><tr><td>Discount</td><td></td><td></td></tr><tr><td style=\"text-align: right\">\(discountText)</td><td>\(discountPct)%</td><td style=\"font-weight:bold;text-align:right;\">($\(discountTotalRounded))</td></tr><tr><td></td><td></td><td></td></tr>")
        }

        table.append("<tr><td>Total Before Taxes</td><td></td><td style=\"font-weight:bold;text-align:right;\">$\(totalAfterDiscountRounded)</td></tr><tr><td></td><td></td><td></td></tr><tr><td>Sales Tax</td><td>\(Int(taxPct*100.0))%</td><td style=\"font-weight:bold;text-align:right;\">$\(taxTotalRounded)</td></tr><tr><td></td><td></td><td></td></tr></table><table style=\"margin:auto;width:50%;min-width: 20em;\"><tr style=\"font-weight:bold;background-color:#555;color:#FFF;\"><td style=\"padding:0.5em;\">Grand Total</td><td style=\"padding:0.5em;text-align:right;\">$\(grandTotalRounded)</td></tr><tr><td></td><td></td></tr></table><br><table style=\"margin:auto;width:50%;min-width: 20em;\"><tr><td>Monthly Renewals</td><td style=\"text-align:right;\">$\(renewalsTotalRounded)</td></tr></table>")
		
		return table
	}
	
	
	func tableForProject(_ project:Project)->String{
		var table = ""
		// header row
        table.append("<table style=\"margin:auto;width:50%;min-width: 20em;\"><tr style=\"background-color:#555;\"><td style=\"color:#FFF; padding:.5em;\"><strong>Description</strong></td><td style=\"color:#FFF; padding:.5em;\"><strong>Quantity</strong></td><td style=\"color:#FFF; padding:.5em;\"><strong>Cost</strong></td></tr>")
		// for each room
//		if let project = Voila.shared.project{
			for room in project.rooms{
				var name = room.name
				if let custom = room.customName { name = custom }
				// first row, room name
				table.append("<tr style=\"background-color:#EEE;\"><td style=\"padding:0.5em\"><strong>" + name + "</strong></td><td></td><td></td></tr>")
				// rows of furniture items in the room
				for furniture in room.furniture{
					if(furniture.name == "All Bathrooms"){
                        table.append("<tr><td>" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\"></td><td></td></tr>")
					} else{
                        table.append("<tr><td>" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\">" + String(describing:furniture.copies) + "</td><td></td></tr>")
					}
				}
				// last row, cost
                table.append("<tr><td></td><td></td><td style=\"padding:0 0.5em 0 0.5em;\"><strong>$" + String(describing:room.getCost()) + "</strong></td></tr>")
			}
        table.append("<tr style=\"background-color:#888\"><td style=\"color:#FFF; padding:.5em;\"><strong>Subtotal</strong></td><td style=\"color:#FFF;\"></td><td style=\"color:#FFF; padding:.5em;\"><strong>$" + String(describing:project.cost()) + "</strong></td></tr>")
//		}
		table.append("</table>")
		return table
	}
    
    func pageHeaderWithTitle(_ title:String) -> String{
		return "<!DOCTYPE html><html><body style=\"background-color: #EEE; padding:2em;font-family:sans-serif;min-width:540px;\"><div style=\"background-color: #FFF; padding:2em;\"><div id=\"custom-note-section\" style=\"text-align:left\">&nbsp;<br>&nbsp;</div><div style=\"text-align:center\"><img style=\"max-height:11em;\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/logo.png?alt=media&token=b84934bf-2584-48e5-9e9c-900c24b782d3\"></div><div style=\"text-align:center\"><p style=\"color:#888;font-size: 1.3em;font-family:serif;\">Home Staging • Re-Styling • Interior Design • Developer Services • Painting</p></div><div style=\"text-align:center;margin-top:3em;margin-bottom:4em;\"><p style=\"margin:auto;width:540px;min-width:480px;color:#888;font-style:italic;font-family:serif;\">Voila Design is Philadelphia’s award winning Home Staging and Interior Design firm. Awarded the \"Best of Philly\" accolade for Home Staging as well as a 26 episode Interior Design agreement with HGTV, the Voila Design team has proven themselves to be an industry leader in the Tri- State Area and beyond. The Voila Design team specializes in preparing properties to sell for the highest market value and in the shortest amount of time. Unlike the competition, Voila Design owns top of the line furnishings, accessories and artwork which allows every Home Staging project to be customized to suit each and every space. The award winning Voila Design team has the unique ability to turn a space from bland to grand in 24 hours or less!</p></div><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"min-width:480px;max-width:540px;height:2px;background-color:#333333;margin:auto\"></div></div><h2 style=\"text-align:center;color:#000;\">Home Staging Proposal<br>" + title + "</h2>"
    }
	
//    var pageHeader = "<!DOCTYPE html><html><body style=\"background-color: #EEE; padding:2em; font-size:.4em;\"><div style=\"background-color: #FFF; padding:2em;\"><div id=\"custom-note-section\" style=\"text-align:left\"><p>&nbsp;</p></div><div style=\"text-align:center\"><img style=\"max-height:11em;\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/logo.png?alt=media&token=b84934bf-2584-48e5-9e9c-900c24b782d3\"></div><div style=\"text-align:center\"><p style=\"color:#888;font-size: 1.3em;\">" +
//        "Home Staging • Re-Styling • Interior Design • Developer Services • Painting" +
//        "</p></div><p style=\"color:#888;font-style: italic;\">" +
//        "Voila Design is Philadelphia’s award winning Home Staging and Interior Design firm. Awarded the \"Best of Philly\" accolade for Home Staging as well as a 26 episode Interior Design agreement with HGTV, the Voila Design team has proven themselves to be an industry leader in the Tri- State Area and beyond. The Voila Design team specializes in preparing properties to sell for the highest market value and in the shortest amount of time. Unlike the competition, Voila Design owns top of the line furnishings, accessories and artwork which allows every Home Staging project to be customized to suit each and every space. The award winning Voila Design team has the unique ability to turn a space from bland to grand in 24 hours or less!" +
//    "</p><h2 style=\"text-align:center;\">Home Staging Proposal</h2>"
	
//    func titleForProject(_ project:Project) -> String{
//        var unitTitle = "";
//        unitTitle = project.name
//        return "<h2 style=\"text-align:center;\">" + unitTitle + "</h2>"
//    }
	func firebaseButton(key:String) -> String{
		return ""
//		return "<br><br><div style=\"margin-top:2em;margin-bottom:2em;text-align:center;\"><a href=\"http://robbykraft.com/confirm.html?\(key)\" style=\"padding:1em;background-color:#555555;color:#FFFFFF;text-decoration:none\">CONFIRM</a></div><br><br>"
	}
	
	// javascript doesn't work in emails
	//	func printButton() -> String{
	//		return "<br><br><div style=\"margin-top:2em;margin-bottom:2em;text-align:center;\"><a href=\"#\" onclick=\"window.print()\" style=\"padding:1em;background-color:#555555;color:#FFFFFF;text-decoration:none\">PRINT</a></div><br><br>"
	//	}
    
    var pageFooter = "<br><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"width:100%;height:2px;background-color:#333333;margin:auto\"></div></div><div style=\"text-align:center;font-size:0.66em;\"><h4>Credit Card Authorization</h4><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"\">Credit Card Type</td><td>Visa</td><td>MC</td><td>Discover</td><td>Amex</td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"text-align:right;\">Name as it appears on card</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Credit card number</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Expiration date</td><td style=\"border-bottom:1px solid black; width:30%;\"></td><td>Security code</td><td style=\"border-bottom:1px solid black; width:30%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Billing Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">&nbsp;</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Email Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><p style=\"font-size:.6em;\">Credit card information is kept for the term of the contract</p><br><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"width:100%;height:2px;background-color:#333333;margin:auto\"></div></div><br><h3>Return signed copy to:</h3><p>Voila Design Home Services LLC<br>2011 Pine St<br>Philadelphia, PA, 19103<br>267.688.2520</p><h3>Or via Email at:</h3><p><a href=\"mailto:tiffanyfasone@gmail.com\" style=\"color:black;\">tiffanyfasone@gmail.com</a></p><p><a href=\"mailto:tiffany@voiladesignhome.com\" style=\"color:black;\">tiffany@voiladesignhome.com</a></p><br><br><table style=\"margin:auto; width:90%; text-align: left\"><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\">Proposal Accepted By</td></tr><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\"><table style=\"margin:auto; width:100%;\"><tr><td>Signature</td><td>Date</td></tr></table></td></tr></table></div><div style=\"background-color:#333333;padding:5em;margin-top:3em;\"><div style=\"text-align:center;\"><table style=\"margin:auto;\"><tr><td style=\"padding:1em;\"><a href=\"https://www.facebook.com/voiladesignhome/\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/facebook.png?alt=media&token=a4d7ee8f-04d5-4f55-b3d6-d0623a43814d\"></a></td><td style=\"padding:1em;\"><a href=\"https://www.instagram.com/voiladesignhome/\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/instagram.png?alt=media&token=d434af0c-5f58-4e00-81a4-2c7eff9db6ff\"></a></td><td style=\"padding:1em;\"><a href=\"https://twitter.com/voiladesignhome\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/twitter.png?alt=media&token=daeba229-b8ae-4138-af89-92d265e8659c\"></a></td></tr></table></div><p style=\"font-size:0.75em;text-align:center;color:#DDDDDD\">Voila Design Home Services LLC<br>2011 Pine St<br>Philadelphia, PA, 19103<br>267.688.2520</p><div style=\"width:100%;height:3px;background-color:#555555;margin:2em 0 2em 0;\"></div><div style=\"font-size:0.6em;color:#DDDDDD\"><h4 style=\"margin-bottom:0\">a) Definitions:</h4><p style=\"margin-top:0\">Home Staging - Terms and Conditions<br>Base Contract: includes delivery of home staging services such as designer time, furniture moving in and out of property, transportation cost, rental of furniture and accessories for the preset period of time, typically three months. It is billed as one-time charge upon delivery.<br>Renewal Fee: includes rental of furniture and accessories for following periods upon Base Contract expiration. It is billed on a monthly base.</p><h4 style=\"margin-bottom:0\">b) Payment terms</h4><p style=\"margin-top:0\">Upon accepting this proposal an advance payment of 50% of Base Contract price is due in order to secure a slot on our schedule. Balance payment is due 7 days before staging services are delivered and before any additional changes are made, if requested.<br>Base Contract fee shall not be prorated if the home sells prior to the end of the contract.</p><h4 style=\"margin-bottom:0\">c) Sales Tax</h4><p style=\"margin-top:0\">Sales Tax is applied to home staging services.</p><h4 style=\"margin-bottom:0\">d) Payments methods</h4><p style=\"margin-top:0\">Credit Cards and QuickBooks \"Pay Now\" feature: <strong>A processing fee of 2% of the transaction value is added to the total charge</strong>.<br>Checks: can be mailed to <strong>Voila Design Home Services LLC, 2011 Pine St, Philadelphia PA 19103</strong></p><h4 style=\"margin-bottom:0\">e) When the property sells</h4><p style=\"margin-top:0\">If the staged property goes under contract and passes most contingencies during the Base Contract time period, 7 days’ notice must be given in order to secure a pull date for removal of furniture out of the property. In case the removal’s request is received with less than 7 days’ notice a \"Rush Removal Fee\" of $250 will be automatically charged to Client.<br>If the property sells but Voila Design Home Services does not receive any notification or request for removal of furniture the Base Contract will continue and renewal fees will be eventually due.<br>If the staged property sells 48 hours before scheduled staging, Client may be charged 15% of staging costs for restocking.</p><h4 style=\"margin-bottom:0\">f) Renewals Terms</h4><p style=\"margin-top:0\">When a Base Contract expires the Renewal Fee is due on monthly basis unless a request for furniture removal is sent to Voila Design Home Services within 7 days from Base Contract expiration date or any following renewal expiration date.<br>Unless other form of payment is provided, Renewal fees are automatically charged to Client’s credit card the first day of the renewal period.<br>Voila Design Home Services reserves the right to remove furniture from staged property in case of failure in monthly Renewal Fee payment.</p><h4 style=\"margin-bottom:0\">g) Disclaimer</h4><p style=\"margin-top:0\">Client acknowledges that this staging contract is independent by any other real estate sales contract, agreement or arrangements between the Client and any other party such as, but not limited to: Buyer, Seller, developer, other contractors or real estate agencies involved in the listing, sale or purchase transactions.</p><h4 style=\"margin-bottom:0\">h) Client’s responsibilities</h4><p style=\"margin-top:0\">Client agrees to allow access to the staged property to Voila Design Home Services employees during regular business hours (Monday to Friday 8.00am to 5.00 pm).<br>Client agrees to provide lock box and alarm codes for staged property as well as to keep keys in the lock box at all times during the length of this contract. Clients shall notify Voila Design Home Services when codes change.<br>Client is liable to take good care of the staged property, to maintain furniture in safe condition and to return all items to Voila Design Home Services in the condition received.<br>Client agrees to refund Voila Design Home Staging for any missing or damaged furniture item or accessories, including items missing or damaged as result of theft, vandalism, flood or fire at the property staged.<br>Client acknowledges that furnishings and accessories are owned by Voila Design Home Services and are intended for display purposes only. If there is evidence of habitation during the rental period, a cleaning/repair fee will be charged to client of at least $500.<br>Client acknowledges and agrees that all furnishings shall remain at the staged property during the entire term of this agreement and shall not be removed from the property, except by Voila Design Home Services’ staff.<br>Client is responsible to pay any third party fee such as move in/out fee, elevator fee, as required to deliver or remove the stage furniture.<br>All added personal items must be removed from the property prior to the final removal from the Voila Design Home Team. If personal items are added to the stage, Voila Design Home is not responsible if items are missing after the staging furniture and accessories are removed.<br>Client is responsible to ensure that the property is finished and ready for staging. This includes the interior unit, and corridors and stairwells leading to the unit, exterior of the building, outlining premises, and street to the building. If Voila Design Home Services’ team arrives to the property and is unable to deliver, client will be charged a $350 fee each time.<br>Voila Design Home Services is aware of the bedbug risks; we take extra measures to be pro-active in preventing an infestation. If an infestation should occur during the rental period, Voila Design Home Services will not be held liable for the damages. Furthermore, infestation will be considered a total loss and client is responsible for replacing the full value of the staging furniture.</p><h4 style=\"margin-bottom:0\">i) Our Commitment</h4><p style=\"margin-top:0\">Voila Design Home Services’ team has the knowledge and proper experience to understand the aesthetics of any room. This is validated by the rate at which homes are sold as a result of Voila Design Home Service’s staging.<br>If Client is unhappy with the condition (damaged or dirty) pieces that are selected for the space, we will re-evaluate one time if necessary at no cost. A fee will apply for any additional re-evaluation.</p></div></div><br><br></div></body></html>"
	
//    var pageFooter = "<br><br><div style=\"text-align:center\"><table style=\"margin:auto; width:90%; text-align: left\"><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\">Proposal Accepted By</td></tr><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\"><table style=\"margin:auto; width:100%;\"><tr><td>Signature</td><td>Date</td></tr></table></td></tr></table><br><br><h4>Credit Card Authorization</h4><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"\">Credit Card Type</td><td>Visa</td><td>MC</td><td>Discover</td><td>Amex</td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"text-align:right;\">Name as it appears on card</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Credit card number</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Expiration date</td><td style=\"border-bottom:1px solid black; width:30%;\"></td><td>Security code</td><td style=\"border-bottom:1px solid black; width:30%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Billing Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">&nbsp;</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Email Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><p style=\"font-size:.6em;\">Credit card information is kept for the term of the contract</p><br><hr><br><h3>Return signed copy to:</h3><p>Voila Design Home Services LLC<br>2011 Pine St<br>Philadelphia, PA, 19103<br>267.688.2520</p><h3>Or via Email at:</h3><p><a href=\"mailto:tiffanyfasone@gmail.com\">tiffanyfasone@gmail.com</a></p><p><a href=\"mailto:tiffany@voiladesignhome.com\">tiffany@voiladesignhome.com</a></p></div></div></body></html>"
	
//    var termsAndConditionsText = "<hr><h3 style=\"text-align:center;\">Home Staging Terms and Conditions</h3><div style=\"font-size: .8em;\"><h4>a) Definitions:</h4><p>Home Staging - Terms and Conditions<br>Base Contract: includes delivery of home staging services such as designer time, furniture moving in and out of property, transportation cost, rental of furniture and accessories for the preset period of time, typically three months. It is billed as one-time charge upon delivery.<br>Renewal Fee: includes rental of furniture and accessories for following periods upon Base Contract expiration. It is billed on a monthly base.</p><h4>b) Payment terms</h4><p>Upon accepting this proposal an advance payment of 50% of Base Contract price is due in order to secure a slot on our schedule. Balance payment is due 7 days before staging services are delivered and before any additional changes are made, if requested.<br>Base Contract fee shall not be prorated if the home sells prior to the end of the contract.</p><h4>c) Sales Tax</h4><p>Sales Tax is applied to home staging services.</p><h4>d) Payments methods</h4><p>Credit Cards and QuickBooks \"Pay Now\" feature: <strong>A processing fee of 2% of the transaction value is added to the total charge</strong>.<br>Checks: can be mailed to <strong>Voila Design Home Services LLC, 2011 Pine St, Philadelphia PA 19103</strong></p><h4>e) When the property sells</h4><p>If the staged property goes under contract and passes most contingencies during the Base Contract time period, 7 days’ notice must be given in order to secure a pull date for removal of furniture out of the property. In case the removal’s request is received with less than 7 days’ notice a \"Rush Removal Fee\" of $250 will be automatically charged to Client.<br>If the property sells but Voila Design Home Services does not receive any notification or request for removal of furniture the Base Contract will continue and renewal fees will be eventually due.<br>If the staged property sells 48 hours before scheduled staging, Client may be charged 15% of staging costs for restocking.</p><h4>f) Renewals Terms</h4><p>When a Base Contract expires the Renewal Fee is due on monthly basis unless a request for furniture removal is sent to Voila Design Home Services within 7 days from Base Contract expiration date or any following renewal expiration date.<br>Unless other form of payment is provided, Renewal fees are automatically charged to Client’s credit card the first day of the renewal period.<br>Voila Design Home Services reserves the right to remove furniture from staged property in case of failure in monthly Renewal Fee payment.</p><h4>g) Disclaimer</h4><p>Client acknowledges that this staging contract is independent by any other real estate sales contract, agreement or arrangements between the Client and any other party such as, but not limited to: Buyer, Seller, developer, other contractors or real estate agencies involved in the listing, sale or purchase transactions.</p><h4>h) Client’s responsibilities</h4><p>Client agrees to allow access to the staged property to Voila Design Home Services employees during regular business hours (Monday to Friday 8.00am to 5.00 pm).<br>Client agrees to provide lock box and alarm codes for staged property as well as to keep keys in the lock box at all times during the length of this contract. Clients shall notify Voila Design Home Services when codes change.<br>Client is liable to take good care of the staged property, to maintain furniture in safe condition and to return all items to Voila Design Home Services in the condition received.<br>Client agrees to refund Voila Design Home Staging for any missing or damaged furniture item or accessories, including items missing or damaged as result of theft, vandalism, flood or fire at the property staged.<br>Client acknowledges that furnishings and accessories are owned by Voila Design Home Services and are intended for display purposes only. If there is evidence of habitation during the rental period, a cleaning/repair fee will be charged to client of at least $500.<br>Client acknowledges and agrees that all furnishings shall remain at the staged property during the entire term of this agreement and shall not be removed from the property, except by Voila Design Home Services’ staff.<br>Client is responsible to pay any third party fee such as move in/out fee, elevator fee, as required to deliver or remove the stage furniture.<br>All added personal items must be removed from the property prior to the final removal from the Voila Design Home Team. If personal items are added to the stage, Voila Design Home is not responsible if items are missing after the staging furniture and accessories are removed.<br>Client is responsible to ensure that the property is finished and ready for staging. This includes the interior unit, and corridors and stairwells leading to the unit, exterior of the building, outlining premises, and street to the building. If Voila Design Home Services’ team arrives to the property and is unable to deliver, client will be charged a $350 fee each time.<br>Voila Design Home Services is aware of the bedbug risks; we take extra measures to be pro-active in preventing an infestation. If an infestation should occur during the rental period, Voila Design Home Services will not be held liable for the damages. Furthermore, infestation will be considered a total loss and client is responsible for replacing the full value of the staging furniture.</p><h4>i) Our Commitment</h4><p>Voila Design Home Services’ team has the knowledge and proper experience to understand the aesthetics of any room. This is validated by the rate at which homes are sold as a result of Voila Design Home Services’estaging.<br>If Client is unhappy with the condition (damaged or dirty) pieces that are selected for the space, we will re-evaluate one time if necessary at no cost. A fee will apply for any additional re-evaluation.</p></div>"
	

}

//
//  PDFMaker.swift
//  Voila
//
//  Created by Robby Kraft on 2/25/19.
//  Copyright © 2019 Robby Kraft. All rights reserved.
//

import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {
	
	let A4PageWidth: CGFloat = 595.2
	let A4PageHeight: CGFloat = 841.8
	let letterWidth: CGFloat = 612
	let letterHeight: CGFloat = 792

	override init() {
		super.init()
		
		let margin: CGFloat = 20
		// Specify the frame of the A4 page.
		let pageFrame = CGRect(x: 0.0, y: 0.0, width: letterWidth, height: letterHeight)
		let printFrame = CGRect(x: margin, y: margin, width: letterWidth - margin*2, height: letterHeight - margin*2)

//		self.paperRect = pageFrame
//		self.printableRect = pageFrame
		
		// Set the page frame.
		self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
		
		// Set the horizontal and vertical insets (that's optional).
		self.setValue(NSValue(cgRect: printFrame), forKey: "printableRect")
	}
	
//	override var numberOfPages: Int{
//		return 10
//	}
}

class PDFMaker {

	static let shared = PDFMaker()
	
	func sendProposal(_ viewController:UIViewController){
		if let project = Voila.shared.project{
			if project.email != nil && project.email! != "" {
			}
		}
	}
	
	func pdfProposal(project:Project, confirmKey:String) -> NSData?{
		
		let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "pdf-template", ofType: "html")
//		let companyLogo = Bundle.main.path(forResource: "logo", ofType: "png")!

		do {
			var htmlString = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
			let tableOfCosts = self.tableForProject(project) + self.tableOfCostsForProject(project)

			htmlString = htmlString.replacingOccurrences(of: "#TITLE#", with: project.name)
			htmlString = htmlString.replacingOccurrences(of: "#TABLE#", with: tableOfCosts)
			
//			htmlString = htmlString.replacingOccurrences(of: "#LOGO_IMAGE#", with: "https://raw.githubusercontent.com/robbykraft/Clients/master/Voila/Voila/Assets.xcassets/logo.imageset/logo-small.png")


			let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlString)
//			printFormatter.perPageContentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
			printFormatter.startPage = 0
			
			let printPageRenderer = CustomPrintPageRenderer()
			printPageRenderer.prepare(forDrawingPages: NSMakeRange(0, 10))
			printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
			
//			return drawPDFUsingPrintPageRenderer(printPageRenderer)
			let data = NSMutableData()
			UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
			
			for i in 0..<printPageRenderer.numberOfPages {
				UIGraphicsBeginPDFPage()
				printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
			}
			
			UIGraphicsEndPDFContext()
			return data
		}
		
		catch{
			
		}
		
		return nil
		
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
		
		let discountTotalRounded = discountTotal
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
//		table.append("<table style=\"margin:auto;width:50%;min-width: 20em;\"><tr style=\"background-color:#555;\"><td style=\"color:#FFF; padding:.5em;\"><strong>Description</strong></td><td style=\"color:#FFF; padding:.5em;\"><strong>Quantity</strong></td><td style=\"color:#FFF; padding:.5em;\"><strong>Cost</strong></td></tr>")
		table.append("<div class=\"cost-container\"><div class=\"grid-container\"><table style=\"margin:auto;width:100%;\"><tr style=\"background-color:#555;\"><td style=\"color:#FFF; padding:.5em; width:50%;\"><strong>Description</strong></td><td style=\"color:#FFF; padding:.5em; width:20%;\"><strong>Quantity</strong></td><td style=\"color:#FFF; padding:.5em; width:25%;\"><strong>Cost</strong></td></tr></table><table style=\"margin:auto;width:100%;\"><tr style=\"background-color:#555;\"><td style=\"color:#FFF; padding:.5em; width:50%;\"><strong>Description</strong></td><td style=\"color:#FFF; padding:.5em; width:20%;\"><strong>Quantity</strong></td><td style=\"color:#FFF; padding:.5em; width:25%;\"><strong>Cost</strong></td></tr></table>")
		// for each room
		//		if let project = Voila.shared.project{
		for room in project.rooms{
			var name = room.name
			if let custom = room.customName { name = custom }
			// first row, room name
			table.append("<table style=\"margin:auto;width:100%;\"><tr style=\"background-color:#EEE;\"><td style=\"padding:0.5em\"><strong>" + name + "</strong></td><td></td><td></td></tr>")
			// rows of furniture items in the room
			for furniture in room.furniture{
				if(furniture.name == "All Bathrooms"){
					table.append("<tr><td>" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\"></td><td></td></tr>")
				} else{
					table.append("<tr><td>" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\">" + String(describing:furniture.copies) + "</td><td></td></tr>")
				}
			}
			// last row, cost
			table.append("<tr><td></td><td></td><td style=\"padding:0 0.5em 0 0.5em;\"><strong>$" + String(describing:room.getCost()) + "</strong></td></tr></table>")
		}
		table.append("<table style=\"margin:auto;width:100%;\"><tr style=\"background-color:#888\"><td style=\"color:#FFF; padding:.5em;\"><strong>Subtotal</strong></td><td style=\"color:#FFF;\"></td><td style=\"color:#FFF; padding:.5em;\"><strong>$" + String(describing:project.cost()) + "</strong></td></tr>")
		//		}
		table.append("</table>")
		table.append("</div></div>") // close grid-container, cost-container
		return table
	}
	
	func pageHeaderWithTitle(_ title:String) -> String{
		return "<!DOCTYPE html><html><body style=\"background-color: #EEE; padding:2em;font-family:sans-serif;min-width:540px;\"><div style=\"background-color: #FFF; padding:2em;\"><div id=\"custom-note-section\" style=\"text-align:left\">&nbsp;<br>&nbsp;</div><div style=\"text-align:center\"><img style=\"max-height:11em;\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/logo-new.png?alt=media&token=be4cc8fa-5b0f-4b83-9f23-5d7f9be5663f\"></div><div style=\"text-align:center\"><p style=\"color:#888;font-size: 1.3em;font-family:serif;\">Home Staging • Re-Styling • Interior Design • Developer Services • Painting</p></div><div style=\"text-align:center;margin-top:3em;margin-bottom:4em;\"><p style=\"margin:auto;width:540px;min-width:480px;color:#888;font-style:italic;font-family:serif;\">Voila Design is Philadelphia’s award winning Home Staging and Interior Design firm. Awarded the \"Best of Philly\" accolade for Home Staging as well as a 26 episode Interior Design agreement with HGTV, the Voila Design team has proven themselves to be an industry leader in the Tri- State Area and beyond. The Voila Design team specializes in preparing properties to sell for the highest market value and in the shortest amount of time. Unlike the competition, Voila Design owns top of the line furnishings, accessories and artwork which allows every Home Staging project to be customized to suit each and every space. The award winning Voila Design team has the unique ability to turn a space from bland to grand in 24 hours or less!</p></div><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"min-width:480px;max-width:540px;height:2px;background-color:#333333;margin:auto\"></div></div><h2 style=\"text-align:center;color:#000;\">Home Staging Proposal<br>" + title + "</h2>"
	}

	
	var pageFooter = "<br><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"width:100%;height:2px;background-color:#333333;margin:auto\"></div></div><div style=\"text-align:center;font-size:0.66em;\"><h4>Credit Card Authorization</h4><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"\">Credit Card Type</td><td>Visa</td><td>MC</td><td>Discover</td><td>Amex</td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"max-width:100%;white-space:nowrap;\"><td style=\"text-align:right;\">Name as it appears on card</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Credit card number</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Expiration date</td><td style=\"border-bottom:1px solid black; width:30%;\"></td><td>Security code</td><td style=\"border-bottom:1px solid black; width:30%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Billing Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">&nbsp;</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr style=\"\"><td style=\"text-align:right;\">Email Address</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><table style=\"margin:auto; width:90%;\"><tr><td style=\"text-align:right;\">Lockbox and entry info</td><td style=\"border-bottom:1px solid black; width:70%;\"></td></tr></table><br><p style=\"font-size:.6em;\">Credit card information is kept for the term of the contract</p><br><div style=\"text-align:center;margin:1em 0 1em 0;\"><div style=\"width:100%;height:2px;background-color:#333333;margin:auto\"></div></div><br><h3>Return signed copy to:</h3><p>Voila Design Home Services LLC<br>2011 Pine St<br>Philadelphia, PA, 19103<br>267.688.2520</p><h3>Or via Email at:</h3><p><a href=\"mailto:tiffanyfasone@gmail.com\" style=\"color:black;\">tiffanyfasone@gmail.com</a></p><p><a href=\"mailto:tiffany@voiladesignhome.com\" style=\"color:black;\">tiffany@voiladesignhome.com</a></p><br><br><table style=\"margin:auto; width:90%; text-align: left\"><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\">Proposal Accepted By</td></tr><tr style=\"\"><td style=\"border:1px solid black; width:100%;height:3em; padding:0.5em;\"><table style=\"margin:auto; width:100%;\"><tr><td>Signature</td><td>Date</td></tr></table></td></tr></table></div><div style=\"background-color:#333333;padding:5em;margin-top:3em;\"><div style=\"text-align:center;\"><table style=\"margin:auto;\"><tr><td style=\"padding:1em;\"><a href=\"https://www.facebook.com/voiladesignhome/\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/facebook.png?alt=media&token=a4d7ee8f-04d5-4f55-b3d6-d0623a43814d\"></a></td><td style=\"padding:1em;\"><a href=\"https://www.instagram.com/voiladesignhome/\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/instagram.png?alt=media&token=d434af0c-5f58-4e00-81a4-2c7eff9db6ff\"></a></td><td style=\"padding:1em;\"><a href=\"https://twitter.com/voiladesignhome\"><img width=\"50%\" src=\"https://firebasestorage.googleapis.com/v0/b/voila-a01f0.appspot.com/o/twitter.png?alt=media&token=daeba229-b8ae-4138-af89-92d265e8659c\"></a></td></tr></table></div><p style=\"font-size:0.75em;text-align:center;color:#DDDDDD\">Voila Design Home Services LLC<br>2011 Pine St<br>Philadelphia, PA, 19103<br>267.688.2520</p><div style=\"width:100%;height:3px;background-color:#555555;margin:2em 0 2em 0;\"></div><div style=\"font-size:0.6em;color:#DDDDDD\"><ol style=\"padding-left:10px;\"><li>Definitions</li><ol style=\"padding-left:10px;\" type=\"a\"><li><b>Base Contract:</b> includes delivery of home staging services such as designer time, furniture moving in and out of property, transportation cost, rental of furniture and accessories for the preset period of time (typically three months).  It is billed as a one-time charge upon delivery.</li></ol><li>Term</li><ol style=\"padding-left:10px;\" type=\"a\"><li>The term of this Agreement is 3 months beginning from date of the staging unless otherwise agreed in the signed proposal.</li><li>The Base Contract can be renewed on a month-to-month basis as outlined in Section 7.</li></ol><li>Choice of Law</li><ol style=\"padding-left:10px;\" type=\"a\"><li>This Lease shall be governed by and construed in accordance with the laws of the State of Pennsylvania.</li></ol><li>Payment Terms</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Upon acceptance of this proposal, an advance payment of 50% of Base Contract price is due in order to secure a delivery slot in the schedule. The balance of the payment is due 7 days before staging services are delivered and before any additional changes are made, if requested.</li><li>Base Contract fee shall not be prorated if the home sells prior to the end of the contract.</li><li>Sales Tax is applied to home staging services.</li></ol><li>Payments methods</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Credit Cards and QuickBooks Pay Now feature: A processing fee of 2% of the transaction value is added to the total charge</li><li>Checks*: can be mailed to:</li><p><i>Voila Design Home Services LLC, 2011 Pine St, Philadelphia PA 19103</i></p><p><b>*Returned Checks:</b> A $39 handling fee will be charged for any check returned to VOILA DESIGN HOME SERVICES LLC by Client’s bank. A replacement check or cash must be delivered to VOILA DESIGN HOME SERVICES LLC within 24 hours after notice to Client of the check return.</p></ol><li>Permission to Charge Client’s Credit Card</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Client hereby authorizes VOILA DESIGN HOME SERVICES LLC to charge the credit card indicated below for current and future charges arising out of or related to this Agreement including but not limited to, Base Contracts, Renewal Fees, defaults, missing or damaged furniture. This authority is irrevocable.</li></ol><li>After Sale of Home</li><ol style=\"padding-left:10px;\" type=\"a\"><li>If the staged property goes under contract and passes most contingencies during the Base Contract time period, 7 days’ notice must be given in order to secure a date for removal of furniture out of the property.</li><ol style=\"padding-left:10px;\" type=\"i\"><li>In case the removal’s request is received with less than 7 days’ notice, the Rush Removal Fee of $250 will be automatically charged to Client.</li><li>If the property sells but VOILA DESIGN HOME SERVICES LLC does not receive any notification or request for removal of furniture the Base Contract will continue and renewal fees will continue to be billed.</li><li>If the staged property sells 48 hours before scheduled staging, Client may be charged 15% of staging costs for restocking.</li></ol></ol><li>Automatic Renewal</li><ol style=\"padding-left:10px;\" type=\"a\"><li>At the expiration of the base contract, the Renewal Fee is charged on monthly basis unless a request for furniture removal is sent to VOILA DESIGN HOME SERVICES LLC within 7 days from Base Contract expiration date or any following renewal expiration date.</li><li>Unless other form of payment is provided, Renewal fees are automatically charged to Client’s credit card the first day of the renewal period.</li><li>VOILA DESIGN HOME SERVICES LLC reserves the right to remove furniture from staged property in case of failure in monthly Renewal Fee payment.</li></ol><li>Client’s Responsibilities</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Client agrees to allow access to the staged property VOILA DESIGN HOME SERVICES LLC employees during regular business hours (Monday to Friday 8.00am to 5.00 pm).</li><li>Client agrees to provide lock box and alarm codes for staged property as well as to keep keys in the lock box at all times during the length of this contract. Clients shall notify VOILA DESIGN HOME SERVICES LLC when codes change.</li><li>Client is liable to take good care of the staged property, to maintain furniture in safe condition and to return all items to VOILA DESIGN HOME SERVICES LLC in the condition received.</li><li>Client agrees to refund VOILA DESIGN HOME SERVICES LLC for any missing or damaged furniture item or accessories, including items missing or damaged as result of theft, vandalism, flood or fire at the property staged.</li><li>Client acknowledges that furnishings and accessories are owned by VOILA DESIGN HOME SERVICES LLC and are intended for display purposes only. If there is evidence of habitation during the rental period, a cleaning/repair fee will be charged to client of at least $500.</li><li>Client acknowledges and agrees that all furnishings shall remain at the staged property during the entire term of this agreement and shall not be removed from the property, except by VOILA DESIGN HOME SERVICES LLC‘s staff.</li><li>Client is responsible to pay any third party fees such as move in/out fee, elevator fee, as required to deliver or remove the stage furniture.</li><li>Client is responsible to have all personal items removed from the property prior to the final removal from VOILA DESIGN HOME SERVICES LLC.</li><ol style=\"padding-left:10px;\" type=\"i\"><li>If personal items are added to the stage, VOILA DESIGN HOME SERVICES LLC is not responsible if items are missing after the staging furniture and accessories are removed.</li></ol><li>Client is responsible to ensure that the property is finished and ready for staging. This includes the interior unit, and corridors and stairwells leading to the unit, exterior of the building, outlining premises, and street to the building. If VOILA DESIGN HOME SERVICES LLC’s team arrives to the property and is unable to deliver, client will be charged a $350 Delayed Delivery Fee each time.</li></ol><li>Miscellaneous</li><ol style=\"padding-left:10px;\" type=\"a\"><li>VOILA DESIGN HOME SERVICES LLC is aware of the bedbug risks.</li><ol style=\"padding-left:10px;\" type=\"i\"><li>We take extra measures to be pro-active in preventing an infestation.</li><li>If an infestation should occur during the rental period, VOILA DESIGN HOME SERVICES LLC will not be held liable for the damages.</li><li>Furthermore, infestation will be considered a total loss and client is responsible for replacing the full value of the staging furniture.</li></ol><li>VOILA DESIGN HOME SERVICES LLC will hang art and/or other accessories on the walls using small hardware unless specifically requested by Client in writing.</li><ol style=\"padding-left:10px;\" type=\"i\"><li>VOILA DESIGN HOMES SERVICES LLC will not be held liable for patching or repainting any walls after furniture removal.</li><li>VOILA DESIGN HOME SERVICES LLC will work to be as less invasive as possible</li><li>VOILA DESIGN HOME SERVICES LLC does not use “3M” strips.</li></ol></ol><li>Our Commitment</li><ol style=\"padding-left:10px;\" type=\"a\"><li>VOILA DESIGN HOME SERVICES LLC’s team has the knowledge and proper experience to understand the aesthetics of any room.</li><li>This is validated by the rate at which homes are sold as a result of VOILA DESIGN HOME SERVICES LLC’S staging.</li><li>If Client is unhappy with the condition (damaged or dirty) pieces that are selected for the space, we will re-evaluate one time if necessary, at no cost. A Replacement fee will apply for any additional re-evaluation.</li></ol><li>Furniture Condition:</li><ol style=\"padding-left:10px;\" type=\"a\"><li>All Furniture and Equipment is rented “as is”.</li><li>Once the Furniture and Equipment is delivered by VOILA DESIGN HOME SERVICES LLC, the Client shall have 24 hours to inspect the assembled products and raise any claim. Once, delivery is signed for and approved by Client, he/she Client, assumes all risks in the use, operation, and transportation of the Furniture and Equipment. Client shall be solely responsible for compliance with all Federal, State and Local Laws or regulation and all industry standards.</li></ol><li>Cancellation:</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Cancellation of sales order before delivery will result in a cancellation fee equal to 75% (seventy-five) of full contract value as outlined in the Sales Order. Cancellation after delivery will be treated under the early termination provision.</li></ol><li>Disclaimer</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Client acknowledges that this staging contract is independent to any other real estate sales contract, agreement or arrangements between the Client and any other party such as, but not limited to: Buyer, Seller, developer, other contractors or real estate agencies involved in the listing, sale or purchase transactions.</li></ol><li>Warranties:</li><ol style=\"padding-left:10px;\" type=\"a\"><li>VOILA DESIGN HOME SERVICES LLC will deliver the Leased Property in good condition. VOILA DESIGN HOME SERVICES LLC makes no other warranties, express or implied, and specifically disclaims any warranty of fitness for a particular purpose or merchantability.</li></ol><li>Indemnification:</li><ol style=\"padding-left:10px;\" type=\"a\"><li>Client expressly agrees to indemnify VOILA DESIGN HOME SERVICES LLC from and against any and all claims, demands, costs, and judgments arising out of connection with, or resulting from the operations, possession, or use of any Furniture and Equipment. Client shall promptly notify VOILA DESIGN HOME SERVICES LLC of any accident involving the Furniture and Equipment.</li></ol><li>Confidentiality</li><ol style=\"padding-left:10px;\" type=\"a\"><li>All pricing on this quote is confidential.  Breach by the quoted party may result in legal action for damages.</li></ol><li>Entire Agreement</li><ol style=\"padding-left:10px;\" type=\"a\"><li>This Lease Agreement and Disclosure Statement sets forth the entire understanding between the parties. Any amendments or changes hereto other than those related to substitution, deletion or addition of items of Leased Property shall be effective only if in writing and signed by both parties. Amendments substituting, deleting or adding items of Leased Property and changing Client's payment obligations accordingly shall be effective if included in a written addendum prepared by VOILA DESIGN HOME SERVICES LLC and furnished to Client unless Client objects in writing within five (5) days of receipt of the addendum.</li></ol></ol></div></div><br><br></div></body></html>"

	
	
}


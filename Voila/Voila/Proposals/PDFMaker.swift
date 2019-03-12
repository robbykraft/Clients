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
	
//	func sendProposal(_ viewController:UIViewController){
//		if let project = Voila.shared.project{
//			if project.email != nil && project.email! != "" {
//			}
//		}
//	}
	
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
			printPageRenderer.prepare(forDrawingPages: NSMakeRange(0, 5))
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

		table.append("<tr style=\"background-color:#888\"><td style=\"color:#FFF; padding:.5em;\"><strong>Subtotal</strong></td><td style=\"color:#FFF;\"></td><td style=\"color:#FFF; padding:.5em;\"><strong>$" + String(describing:project.cost()) + "</strong></td></tr>")

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
					table.append("<tr><td style=\"padding-right:1.5em;\">" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\"></td><td></td></tr>")
				} else{
					table.append("<tr><td style=\"padding-right:1.5em;\">" + furniture.name + "</td><td style=\"text-align:right;padding-right:0.5em;\">" + String(describing:furniture.copies) + "</td><td></td></tr>")
				}
			}
			// last row, cost
			table.append("<tr><td></td><td></td><td style=\"padding:0 0.5em 0 0.5em;\"><strong>$" + String(describing:room.getCost()) + "</strong></td></tr></table>")
		}
		table.append("</div></div>") // close grid-container, cost-container
		return table
	}
	
}


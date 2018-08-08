//
//  Style.swift
//  Character
//
//  Created by Robby on 8/23/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

let SYSTEM_FONT_B = "AvenirNext-Bold"
let SYSTEM_FONT = "AvenirNext-Medium"

let IS_IPAD:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
let IS_IPHONE:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
let IS_IPHONE_X:Bool = UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.shared.statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}

func getDevice(){
//	if UIDevice().userInterfaceIdiom == .phone {
//		switch UIScreen.main.nativeBounds.height {
//		case 1136: print("iPhone 5 or 5S or 5C")
//		case 1334: print("iPhone 6/6S/7/8")
//		case 2208: print("iPhone 6+/6S+/7+/8+")
//		case 2436: self.view.backgroundColor = UIColor.white
//		default: print("unknown")
//		}
//	}
}

class Style {
	static let shared = Style()
	
	// for the allergy color scheme
	var colorNoPollen = UIColor()
	var colorLow = UIColor()
	var colorMedium = UIColor()
	var colorHeavy = UIColor()
	var colorVeryHeavy = UIColor()
	
	var colorNoEntry = UIColor()

	let gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
	let darkGray = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.00)
	let whiteSmoke = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
	let athensGray = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
	let lightGray = UIColor(red:0.9, green:0.9, blue:0.92, alpha:1.00)
	let red = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1.0)
	let orange = UIColor(red: 255/255.0, green: 149/255.0, blue: 0, alpha: 1.0)
	let yellow = UIColor(red: 210/255.0, green: 170/255.0, blue: 0.1, alpha: 1.0)
	let blue = UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0)
	let green = UIColor(red:0.00, green:0.65, blue:0.22, alpha:1.00)
//	let green = UIColor(red: 76/255.0, green: 217/255.0, blue: 100/255.0, alpha: 1.0)
	let alienGreen = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.00)
	let softBlue = UIColor(red:0.20, green:0.67, blue:0.86, alpha:1.00)
	let lightBlue = UIColor(red:0.53, green:0.77, blue:1.00, alpha:1.00)
	let purple = UIColor(red: 88/255.0, green: 86/255.0, blue: 214/255.0, alpha: 1.0)
	
	var zoomScale:CGFloat = 1.0
	
	var P64:CGFloat = 64
	var P48:CGFloat = 48
	var P40:CGFloat = 40
	var P30:CGFloat = 30
	var P24:CGFloat = 24
	var P21:CGFloat = 21
	var P20:CGFloat = 20
	var P18:CGFloat = 18
	var P15:CGFloat = 15
	var P12:CGFloat = 12
	var P11:CGFloat = 11
	
	private init() {
		// custom initialize
		if(IS_IPAD){
			P64 = 100
			P48 = 84
			P40 = 68
			P30 = 54
			P24 = 41
			P21 = 36
			P20 = 31
			P18 = 27
			P15 = 26
			P12 = 24
			P11 = 16
		}
		
		//iphone 7 2.0 2.0
		//iphone 7plus 3.0 3.0
		// myphone 2.34375 2.0
		zoomScale = UIScreen.main.nativeScale / UIScreen.main.scale
		
		P64 /= zoomScale
		P48 /= zoomScale
		P40 /= zoomScale
		P30 /= zoomScale
		P24 /= zoomScale
		P21 /= zoomScale
		P18 /= zoomScale
		P15 /= zoomScale
		P12 /= zoomScale
		P11 /= zoomScale
		
		colorNoPollen = green
		colorLow = UIColor(red: 0.0, green: 200/255.0, blue: 50/255.0, alpha: 1.0)
		colorMedium = UIColor(red: 1.0, green: 156/255.0, blue: 14/255.0, alpha: 1.0)
		colorHeavy = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1.0)//UIColor(red: 1.0, green: 97/255.0, blue: 28/255.0, alpha: 1.0)
		colorVeryHeavy = purple
		
		colorNoEntry = UIColor.black
		
		styleUIAppearance()
	}
	
	func colorFor(rating:PollenRating)->UIColor{
		switch rating {
		case .none: return self.colorNoPollen
		case .low: return self.colorLow
		case .medium: return self.colorMedium
		case .heavy: return self.colorHeavy
		case .veryHeavy: return self.colorVeryHeavy
		}
	}
		
	func heading1Attributes() -> [String:NSObject] {
		var fontSize:CGFloat = 22
		if(IS_IPAD){
			fontSize = 36
		}
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .center
		let font = UIFont(name: SYSTEM_FONT, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
		return [NSAttributedStringKey.font.rawValue : font,
		        NSAttributedStringKey.kern.rawValue : CGFloat(2.4) as NSObject,
		        NSAttributedStringKey.paragraphStyle.rawValue: titleParagraphStyle,
		        NSAttributedStringKey.foregroundColor.rawValue : UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.00)];
	}
	
	func styleUIAppearance(){
		let navigationBarAppearace = UINavigationBar.appearance()
//		navigationBarAppearace.tintColor = UIColor.white
//		navigationBarAppearace.setBackgroundImage(UIImage.init(named: "darkGray"), for: .default)
//		navigationBarAppearace.barStyle = UIBarStyle.blackTranslucent
		let navBarFont = (IS_IPAD) ? (UIFont(name: SYSTEM_FONT_B, size: P18) ?? UIFont.boldSystemFont(ofSize: P18)) : (UIFont(name: SYSTEM_FONT_B, size: P24) ?? UIFont.boldSystemFont(ofSize: P24))
		navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.font : navBarFont,
		                                              NSAttributedStringKey.foregroundColor : UIColor.black]
	}
	
	
	func dayStringForDate(_ date:Date) -> String{
		if(NSCalendar.current.isDateInToday(date)){
			return "today"
		}
		if(NSCalendar.current.isDateInYesterday(date)){
			return "yesterday"
		}
		if(abs(date.timeIntervalSinceNow) < 432000){
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE"
			return dateFormatter.string(from: date)
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, yyyy"
		return dateFormatter.string(from: date)
	}
	

	func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool, maxAngle: CGFloat?){
		let l = str.count
		var curveFont = font
		let attributes = [NSAttributedStringKey.font: curveFont]
		let characters: [String] = str.map { String($0) }
		var arcs: [CGFloat] = []
		var totalArc: CGFloat = 0
		for i in 0 ..< l {
			arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: r)]
			totalArc += arcs[i]
		}
		if let maxA = maxAngle{
			var newPointSize:CGFloat = curveFont.pointSize
			while(totalArc > maxA && newPointSize > 5){
				newPointSize -= 2
				curveFont = curveFont.withSize(newPointSize)
				let newAttributes = [NSAttributedStringKey.font: curveFont]
				arcs = []
				totalArc = 0
				for i in 0 ..< l {
					arcs += [chordToArc(characters[i].size(withAttributes: newAttributes).width, radius: r)]
					totalArc += arcs[i]
				}
			}
		}
		let direction: CGFloat = clockwise ? -1 : 1
		let slantCorrection = clockwise ? -CGFloat(Double.pi/2) : CGFloat(Double.pi/2)
		var thetaI = theta - direction * totalArc / 2
		
		for i in 0 ..< l {
			thetaI += direction * arcs[i] / 2
			centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: curveFont, slantAngle: thetaI + slantCorrection)
			thetaI += direction * arcs[i] / 2
		}
	}
	
	func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
		return 2 * asin(chord / (2 * radius))
	}
	
	func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
		let attributes = [NSAttributedStringKey.foregroundColor: c, NSAttributedStringKey.font: font]
		context.saveGState()
		context.scaleBy(x: 1, y: -1)
		context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
		context.rotate(by: -slantAngle)
		let offset = str.size(withAttributes: attributes)
		context.translateBy (x: -offset.width / 2, y: -offset.height / 2)
		str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
		context.restoreGState()
	}

}

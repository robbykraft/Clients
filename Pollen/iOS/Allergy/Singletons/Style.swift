//
//  Style.swift
//  Character
//
//  Created by Robby on 8/23/16.
//  Copyright © 2016 Robby. All rights reserved.
//

extension UIColor {
	static func appleBlue() -> UIColor {
		return UIColor(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
	}
}

import UIKit

//let SYSTEM_FONT:String = "ArialRoundedMTBold"
//let SYSTEM_FONT:String = "BanglaSangamMN"
//let SYSTEM_FONT_B:String = "BanglaSangamMN-Bold"
//let SYSTEM_FONT:String = "AppleSDGothicNeo-UltraLight"
//let SYSTEM_FONT_B:String = "AppleSDGothicNeo-Bold"
//let SYSTEM_FONT:String = "Thonburi-Light"
//let SYSTEM_FONT_B:String = "Thonburi-Bold"
let SYSTEM_FONT = "AvenirNext-Medium"
let SYSTEM_FONT_B = "AvenirNext-Bold"


let IS_IPAD:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
let IS_IPHONE:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone


class Style {
	
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
	
	static let shared:Style = {
		let s = Style()

		// custom initialize
		if(IS_IPAD){
			s.P64 = 92
			s.P48 = 72
			s.P40 = 60
			s.P30 = 50
			s.P24 = 36
			s.P21 = 32
			s.P20 = 31
			s.P18 = 27
			s.P15 = 26
			s.P12 = 24
			s.P11 = 16
		}
		
		//iphone 7 2.0 2.0
		//iphone 7plus 3.0 3.0
		// myphone 2.34375 2.0
		s.zoomScale = UIScreen.main.nativeScale / UIScreen.main.scale
		
		s.P64 /= s.zoomScale
		s.P48 /= s.zoomScale
		s.P40 /= s.zoomScale
		s.P30 /= s.zoomScale
		s.P24 /= s.zoomScale
		s.P21 /= s.zoomScale
		s.P18 /= s.zoomScale
		s.P15 /= s.zoomScale
		s.P12 /= s.zoomScale
		s.P11 /= s.zoomScale

		s.colorNoPollen = s.green
		s.colorLow = UIColor(red: 0.0, green: 200/255.0, blue: 50/255.0, alpha: 1.0)
		s.colorMedium = UIColor(red: 1.0, green: 156/255.0, blue: 14/255.0, alpha: 1.0)
		s.colorHeavy = UIColor(red: 1.0, green: 97/255.0, blue: 28/255.0, alpha: 1.0)
		s.colorVeryHeavy = s.red
		
		s.colorNoEntry = UIColor.black
		
		s.styleUIAppearance()

		return s
	}()
	
	func heading1Attributes() -> [String:NSObject] {
		var fontSize:CGFloat = 22
		if(IS_IPAD){
			fontSize = 36
		}
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .center
		return [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: fontSize)!,
		        NSKernAttributeName : CGFloat(2.4) as NSObject,
		        NSParagraphStyleAttributeName: titleParagraphStyle,
		        NSForegroundColorAttributeName : Style.shared.darkGray];
	}
	
	func styleUIAppearance(){
		let navigationBarAppearace = UINavigationBar.appearance()
//		navigationBarAppearace.tintColor = UIColor.white
//		navigationBarAppearace.setBackgroundImage(UIImage.init(named: "darkGray"), for: .default)
//		navigationBarAppearace.barStyle = UIBarStyle.blackTranslucent
		navigationBarAppearace.titleTextAttributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT_B, size: self.P24)!,
		                                              NSForegroundColorAttributeName : UIColor.black]
//		NSKernAttributeName : CGFloat(-4.0)]
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
	
	
	/////////////////////////////////////////////////////////////////////////
	
	func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool, maxAngle: CGFloat?){
		// *******************************************************
		// This draws the String str around an arc of radius r,
		// with the text centred at polar angle theta
		// *******************************************************
		
		let l = str.characters.count
		var curveFont = font
		let attributes = [NSFontAttributeName: curveFont]
		
		let characters: [String] = str.characters.map { String($0) } // An array of single character strings, each character in str
		var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
		var totalArc: CGFloat = 0 // ... and the total arc subtended by the string

		// Calculate the arc subtended by each letter and their total
		for i in 0 ..< l {
			arcs += [chordToArc(characters[i].size(attributes: attributes).width, radius: r)]
			totalArc += arcs[i]
		}

		if let maxA = maxAngle{
			var newPointSize:CGFloat = curveFont.pointSize
			while(totalArc > maxA && newPointSize > 5){
				newPointSize -= 2
				curveFont = curveFont.withSize(newPointSize)
				let newAttributes = [NSFontAttributeName: curveFont]
				arcs = []
				totalArc = 0
				// Calculate the arc subtended by each letter and their total
				for i in 0 ..< l {
					arcs += [chordToArc(characters[i].size(attributes: newAttributes).width, radius: r)]
					totalArc += arcs[i]
				}
			}
		}
	
		
		// Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
		// or anti-clockwise (right way up at 6 o'clock)?
		let direction: CGFloat = clockwise ? -1 : 1
		let slantCorrection = clockwise ? -CGFloat(Double.pi/2) : CGFloat(Double.pi/2)
		
		// The centre of the first character will then be at
		// thetaI = theta - totalArc / 2 + arcs[0] / 2
		// But we add the last term inside the loop
		var thetaI = theta - direction * totalArc / 2
		
		for i in 0 ..< l {
			thetaI += direction * arcs[i] / 2
			// Call centerText with each character in turn.
			// Remember to add +/-90º to the slantAngle otherwise
			// the characters will "stack" round the arc rather than "text flow"
			centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: curveFont, slantAngle: thetaI + slantCorrection)
			// The centre of the next character will then be at
			// thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
			// but again we leave the last term to the start of the next loop...
			thetaI += direction * arcs[i] / 2
		}
	}
	
	func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
		// *******************************************************
		// Simple geometry
		// *******************************************************
		return 2 * asin(chord / (2 * radius))
	}
	
	func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
		// *******************************************************
		// This draws the String str centred at the position
		// specified by the polar coordinates (r, theta)
		// i.e. the x= r * cos(theta) y= r * sin(theta)
		// and rotated by the angle slantAngle
		// *******************************************************
		
		// Set the text attributes
		let attributes = [NSForegroundColorAttributeName: c, NSFontAttributeName: font]
		// Save the context
		context.saveGState()
		// Undo the inversion of the Y-axis (or the text goes backwards!)
		context.scaleBy(x: 1, y: -1)
		// Move the origin to the centre of the text (negating the y-axis manually)
		context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
		// Rotate the coordinate system
		context.rotate(by: -slantAngle)
		// Calculate the width of the text
		let offset = str.size(attributes: attributes)
		// Move the origin by half the size of the text
		context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
		// Draw the text
		str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
		// Restore the context
		context.restoreGState()
	}

}

extension UIImageView {
	func tint(color:UIColor){
		if let image = self.image{
			let newImage = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			self.image = newImage
		}
		self.tintColor = color
	}
}

extension CGRect {
	var bottom:CGFloat{
		return self.origin.y + self.size.height
	}
}

extension UIImage {
	
	func maskWithColor(color: UIColor) -> UIImage? {
		let maskImage = cgImage!
		
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		context.clip(to: bounds, mask: maskImage)
		context.setFillColor(color.cgColor)
		context.fill(bounds)
		
		if let cgImage = context.makeImage() {
			let coloredImage = UIImage(cgImage: cgImage)
			return coloredImage
		} else {
			return nil
		}
	}
	
}

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.shared.statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}


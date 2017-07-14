//
//  Style.swift
//  Character
//
//  Created by Robby on 8/23/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

//let SYSTEM_FONT:String = "ArialRoundedMTBold"

let SYSTEM_FONT:String = "Avenir-Book"
let SYSTEM_FONT_I:String = "Avenir-BookOblique"
let SYSTEM_FONT_B:String = "Avenir-Black"
let SYSTEM_FONT_B_I:String = "Avenir-BlackOblique"

//let SYSTEM_FONT:String = "Optima-Regular"
//let SYSTEM_FONT_B:String = "Optima-ExtraBlack"

let IS_IPAD:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
let IS_IPHONE:Bool = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone


class Style {
	
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
	
	var P40:CGFloat = 40
	var P30:CGFloat = 30
	var P24:CGFloat = 24
	var P18:CGFloat = 18
	var P15:CGFloat = 15
	var P12:CGFloat = 12
	
	static let shared = Style()
	
	fileprivate init() {
		if(IS_IPAD){
			P40 = 60
			P30 = 50
			P24 = 42
			P18 = 32
			P15 = 26
			P12 = 24
		}
		styleUIAppearance()
	}
	
//	func heading1Attributes() -> [String:NSObject] {
//		var fontSize:CGFloat = 22
//		if(IS_IPAD){
//			fontSize = 36
//		}
//		let titleParagraphStyle = NSMutableParagraphStyle()
//		titleParagraphStyle.alignment = .center
//		return [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: fontSize)!,
//		        NSKernAttributeName : CGFloat(2.4) as NSObject,
//		        NSParagraphStyleAttributeName: titleParagraphStyle,
//		        NSForegroundColorAttributeName : Style.shared.darkGray];
//	}
	
	func styleUIAppearance(){
		let navigationBarAppearace = UINavigationBar.appearance()
		navigationBarAppearace.titleTextAttributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT_B, size: self.P18)!,
		                                              NSForegroundColorAttributeName : UIColor.black]
		
//		navigationBarAppearace.tintColor = UIColor.white
//		navigationBarAppearace.setBackgroundImage(UIImage.init(named: "darkGray"), for: .default)
//		navigationBarAppearace.barStyle = UIBarStyle.blackTranslucent
//		navigationBarAppearace.titleTextAttributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
//		                                              NSForegroundColorAttributeName : UIColor.white]
//			                                              NSKernAttributeName : CGFloat(-4.0)]
//		UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT, size: 16)!,
//			NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
//		UITabBar.appearance().shadowImage = UIImage()
//		UITabBar.appearance().backgroundImage = UIImage(named: "gray")
//		UITabBar.appearance().tintColor = UIColor.white
		
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
	
}

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.shared.statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}


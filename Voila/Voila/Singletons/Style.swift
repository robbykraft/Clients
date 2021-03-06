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
	
	let highlight = UIColor(red:0.9, green:0.2, blue:0.3, alpha: 1.0)
	let ecruWhite = UIColor(red:0.97, green:0.96, blue:0.89, alpha:1.00)
	let ecruLight = UIColor(red:0.985, green:0.98, blue:0.94, alpha:1.00)
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
	
//	let cellSelectionColor = UIColor(red:0.95, green:0.935, blue:0.79, alpha:1.00)
	let cellSelectionColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
	
	var P60:CGFloat = 60
	var P48:CGFloat = 48
	var P40:CGFloat = 40
	var P30:CGFloat = 30
	var P24:CGFloat = 24
	var P21:CGFloat = 21
	var P18:CGFloat = 18
	var P15:CGFloat = 15
	var P12:CGFloat = 12
	var P09:CGFloat = 9

	static let shared = Style()
	
	fileprivate init() {
		if(IS_IPAD){
			P60 = 90
			P48 = 70
			P40 = 60
			P30 = 50
			P24 = 42
			P21 = 38
			P18 = 32
			P15 = 26
			P12 = 24
			P09 = 18
		}
		styleUIAppearance()
	}
	
	func styleUIAppearance(){
		let navigationBarAppearace = UINavigationBar.appearance()
		navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: SYSTEM_FONT_B, size: self.P18)!,
													  NSAttributedString.Key.foregroundColor : UIColor.black]
		
		UINavigationBar.appearance().tintColor = self.highlight
		
	}
	
	
	func dayStringForDate(_ date:Date) -> String{
		if(NSCalendar.current.isDateInToday(date)){
			let calendar = Calendar.current
			let hour = calendar.component(.hour, from: date)
			let minutes = calendar.component(.minute, from: date)
			return "Today \(hour):" + String(format: "%02d", minutes)
//			return "Today"
		}
		if(NSCalendar.current.isDateInYesterday(date)){
			let calendar = Calendar.current
			let hour = calendar.component(.hour, from: date)
			let minutes = calendar.component(.minute, from: date)
			return "Yesterday \(hour):" + String(format: "%02d", minutes)
//			return "Yesterday"
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
	
	func dayStringForDateNoYear(_ date:Date) -> String{
		if(NSCalendar.current.isDateInToday(date)){
//            let calendar = Calendar.current
//            let hour = calendar.component(.hour, from: date)
//            let minutes = calendar.component(.minute, from: date)
			return "Today"// \(hour):" + String(format: "%02d", minutes)
			//			return "Today"
		}
		if(NSCalendar.current.isDateInYesterday(date)){
//            let calendar = Calendar.current
//            let hour = calendar.component(.hour, from: date)
//            let minutes = calendar.component(.minute, from: date)
			return "Yesterday"// \(hour):" + String(format: "%02d", minutes)
			//			return "Yesterday"
		}
		if(abs(date.timeIntervalSinceNow) < 432000){
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE"
			return dateFormatter.string(from: date)
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
		return dateFormatter.string(from: date)
	}

}

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.shared.statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}


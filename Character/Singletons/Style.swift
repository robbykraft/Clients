//
//  Style.swift
//  Character
//
//  Created by Robby on 8/23/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

let SYSTEM_FONT:String = "GillSans"
let SYSTEM_FONT_I:String = "GillSans-Italic"

let IS_IPAD:Bool = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
let IS_IPHONE:Bool = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone


class Style {
	
	let lightBlue = UIColor(red:0.33, green:0.65, blue:0.95, alpha:1.00)
	let green = UIColor(red: 0.0, green: 0.8, blue: 0.05, alpha: 1.0)
	let gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
	let darkGray = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.00)
	let whiteSmoke = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
	
	var P40:CGFloat = 40
	var P30:CGFloat = 30
	var P24:CGFloat = 24
	var P18:CGFloat = 18
	var P15:CGFloat = 15
	var P12:CGFloat = 12
	
	static let shared = Style()
	
	private init() {
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
	
	func heading1Attributes() -> [String:NSObject] {
		var fontSize:CGFloat = 22
		if(IS_IPAD){
			fontSize = 36
		}
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .Center
		return [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: fontSize)!,
		        NSKernAttributeName : CGFloat(2.4),
		        NSParagraphStyleAttributeName: titleParagraphStyle,
		        NSForegroundColorAttributeName : Style.shared.darkGray];
	}
	
	func styleUIAppearance(){
		let navigationBarAppearace = UINavigationBar.appearance()
		navigationBarAppearace.tintColor = UIColor.whiteColor()
		navigationBarAppearace.setBackgroundImage(UIImage.init(named: "darkGray"), forBarMetrics: .Default)
		navigationBarAppearace.barStyle = UIBarStyle.BlackTranslucent
		navigationBarAppearace.titleTextAttributes = [NSFontAttributeName : UIFont(name: SYSTEM_FONT, size: 22)!,
		                                              NSForegroundColorAttributeName : UIColor.whiteColor()]
		//	                                              NSKernAttributeName : CGFloat(-4.0)]
		UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: SYSTEM_FONT, size: 16)!,
			NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
		UITabBar.appearance().shadowImage = UIImage()
		UITabBar.appearance().backgroundImage = UIImage(named: "gray")
		UITabBar.appearance().tintColor = UIColor.whiteColor()
		
	}
}

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}


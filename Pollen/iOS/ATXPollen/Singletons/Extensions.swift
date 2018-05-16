//
//  Style.swift
//  Character
//
//  Created by Robby on 8/23/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

extension Date {
	func isLessThanDate(_ dateToCompare: Date) -> Bool {
		//Declare Variables
		var isLess = false
		//Compare Values
		if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
			isLess = true
		}
		//Return Result
		return isLess
	}

	func toString() -> String{
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: self)
	}
	init?(fromString:String){
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		if let success = formatter.date(from: fromString){ self = success }
		else { return nil }
	}
	//	mutating func from(string:String){
	//		let formatter = DateFormatter()
	//		formatter.dateFormat = "yyyy-MM-dd"
	//		if let success = formatter.date(from: string){ self = success }
	//	}
}

extension UIColor {
	static func appleBlue() -> UIColor {
		return UIColor(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
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

extension UIImage{
	public func imageWithTint(_ color:UIColor) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()
		context?.translateBy(x: 0, y: self.size.height)
		context?.scaleBy(x: 1.0, y: -1.0)
		let rect:CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context?.setBlendMode(.normal)
		context?.draw(self.cgImage!, in: rect)
		context?.setBlendMode(.sourceIn)
		color.setFill()
		context?.fill(rect)
		let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return tintedImage!
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

import UIKit

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
}

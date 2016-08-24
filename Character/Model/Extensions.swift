import UIKit

extension UIImage{
	public func imageWithTint(color:UIColor) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
		let context = UIGraphicsGetCurrentContext()
		CGContextTranslateCTM(context, 0, self.size.height)
		CGContextScaleCTM(context, 1.0, -1.0)
		let rect:CGRect = CGRectMake(0, 0, self.size.width, self.size.height)
		CGContextSetBlendMode(context, .Normal)
		CGContextDrawImage(context, rect, self.CGImage)
		CGContextSetBlendMode(context, .SourceIn)
		color.setFill()
		CGContextFillRect(context, rect)
		let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return tintedImage
	}
}

//
//  Modal.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/8/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

protocol Modal {
	func show(animated:Bool)
	func dismiss(animated:Bool)
	var backgroundView:UIView {get}
	var dialogView:UIView {get set}
}

extension Modal where Self:UIView{
	
	func show(animated:Bool){
		self.backgroundView.alpha = 0
		self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
		if animated {
			UIView.animate(withDuration: 0.33, animations: {
				self.backgroundView.alpha = 0.66
			})
			UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
				self.dialogView.center  = self.center
			}, completion: { (completed) in
				
			})
		}else{
			self.backgroundView.alpha = 0.66
			self.dialogView.center  = self.center
		}
	}
	
	func dismiss(animated:Bool){
		if animated {
			UIView.animate(withDuration: 0.33, animations: {
				self.backgroundView.alpha = 0
			}, completion: { (completed) in
				
			})
			UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
				self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
			}, completion: { (completed) in
				self.removeFromSuperview()
			})
		}else{
			self.removeFromSuperview()
		}
	}
}

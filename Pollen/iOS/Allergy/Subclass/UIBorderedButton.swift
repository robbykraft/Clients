//
//  UIBorderedButton.swift
//  Allergy
//
//  Created by Robby Kraft on 5/11/18.
//  Copyright © 2018 Robby Kraft. All rights reserved.
//

import UIKit

class UIBorderedButton: UIButton {
	
	var color:UIColor = UIColor.black{
		didSet{
			self.setTitleColor(self.color, for: .normal)
			self.layer.borderColor = self.color.cgColor
		}
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
		self.initUI()
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initUI()
	}
	
	func initUI(){
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDown)
		self.addTarget(self, action: #selector(buttonSetSelected), for: .touchDragEnter)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragOutside)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchCancel)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchDragExit)
		self.addTarget(self, action: #selector(buttonSetUnselected), for: .touchUpInside)

		self.setTitleColor(self.color, for: .normal)
		self.layer.borderColor = self.color.cgColor
		self.layer.backgroundColor = UIColor.white.cgColor
		
		self.layer.cornerRadius = 12
		self.layer.borderWidth = 3
		self.sizeToFit()
	}
	
	func buttonSetSelected(){
		self.layer.backgroundColor = self.color.cgColor
		self.setTitleColor(UIColor.white, for: .normal)
	}
	func buttonSetUnselected(){
		self.layer.backgroundColor = UIColor.white.cgColor
		self.setTitleColor(self.color, for: .normal)
	}
	

}

//
//  PopAlertView.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/8/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit

class PopAlertView: UIView, Modal{
	var backgroundView = UIView()
	var dialogView = UIView()
	var view:UIView?
	
	convenience init(title:String, view:UIView) {
		self.init(frame: UIScreen.main.bounds)
		initUI(title: title, view: view)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initUI(title:String, view:UIView){
		self.view = view
		
		backgroundView.frame = frame
		backgroundView.backgroundColor = UIColor.black
		backgroundView.alpha = 0.6
		addSubview(backgroundView)
		let dialogViewWidth = frame.width-64
		
		let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
		titleLabel.font = UIFont(name: SYSTEM_FONT_B, size: Style.shared.P24)
		titleLabel.text = title
		titleLabel.textAlignment = .center
		dialogView.addSubview(titleLabel)

		view.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + titleLabel.frame.origin.y + 9)
		view.frame.size = CGSize(width: dialogViewWidth, height: view.frame.size.height)
		view.layer.cornerRadius = 4
		view.clipsToBounds = true
		dialogView.addSubview(view)

		let separatorLineView = UIView()
		separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + titleLabel.frame.origin.y + 8)
		separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
		separatorLineView.backgroundColor = UIColor.groupTableViewBackground
		dialogView.addSubview(separatorLineView)

		let dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + view.frame.height + 8
		dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
		dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
		dialogView.backgroundColor = UIColor.white
		dialogView.layer.cornerRadius = 6
		dialogView.clipsToBounds = true
		addSubview(dialogView)
		backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
	}
	
	@objc func didTappedOnBackgroundView(){
		dismiss(animated: true)
	}
}


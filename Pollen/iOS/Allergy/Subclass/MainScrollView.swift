//
//  MainScrollView.swift
//  Allergy
//
//  Created by Robby on 10/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class MainScrollView: UIScrollView {

	override func touchesShouldCancel(in view: UIView) -> Bool {
		return true
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		return self.subviews
			.map { (view) -> Bool in
				return view.frame.contains(point)
//				return view.point(inside: point, with: event)
			}
			.reduce(false, { $0 || $1 })
	}

}

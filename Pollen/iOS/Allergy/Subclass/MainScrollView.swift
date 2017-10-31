//
//  MainScrollView.swift
//  Allergy
//
//  Created by Robby on 10/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

class MainScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	override func touchesShouldCancel(in view: UIView) -> Bool {
		return true
	}

}

//
//  SliderTableViewCell.swift
//  Allergy
//
//  Created by Robby on 4/12/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit

protocol SliderCellDelegate: class {
	func didMoveSlider(sender: UISlider)
}

class SliderTableViewCell: UITableViewCell {

	weak var delegate:SliderCellDelegate?
	
	let slider = UISlider()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initUI()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		initUI()
	}
	
	func initUI(){
		slider.addTarget(self, action: #selector(didMoveSlider), for: .valueChanged)
		self.addSubview(slider)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		slider.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width*0.8, height: 44)
		slider.center = CGPoint(x: self.frame.size.width*0.5, y: self.frame.size.height*0.5)
	}
	
	func didMoveSlider(){
		if(delegate != nil){
			delegate?.didMoveSlider(sender: self.slider)
		}
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

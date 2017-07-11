//
//  Furniture.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Furniture{
	var name:String = ""
	var price:Int = 0
	var room:Room?
	
	init(name:String, price:Int, room:Room){
		self.name = name
		self.price = price
		self.room = room
	}
}

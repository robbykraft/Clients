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
	var price:Float = 0
	var room:Room?
	
	var copies:Int = 1 // in a room of furniture items, copies of furniture stored here
	
	init(name:String, price:Float, room:Room?){
		self.name = name
		self.price = price
		self.room = room
	}
}

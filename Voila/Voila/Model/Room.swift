//
//  Room.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Room{
	var key:String = ""
	var name:String = "" // room name in database
	var customName:String? // rename a room
	
	var furniture:[Furniture] = []
	
	init(key:String, name:String){
		self.key = key
		self.name = name
	}
	
}

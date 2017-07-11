//
//  Project.swift
//  Voila
//
//  Created by Robby on 7/11/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Project{
	var key:String = "" // the key in the database under "projects"

	var name:String = ""
	var active:Bool = true
	
	// contains furniture inside each room
	var rooms:[Room] = []
	
	init(key:String, data:[String:Any]){
		self.key = key
		
		if let name = data["name"] as? String { self.name = name }
		if let active = data["active"] as? Bool { self.active = active }
		if let content = data["content"] as? [String:Any] {
			for (key, value) in content{
				
			}
		}
		
	}
	
	func update(completionHandler:@escaping() -> ()){
		
	}
	
}

//
//  Record.swift
//  Allergy
//
//  Created by Robby on 10/27/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import Foundation

class Record {
	
	var date:Date = Date()
	
	var congestion:Int = 0
	var runny:Int = 0
	var itchy:Int = 0
	var sneezy:Int = 0
	var sleepy:Int = 0
	
	init(date:Date) {
		self.date = date
	}
	func fill(congestion:Int?, runny:Int?, itchy:Int?, sneezy:Int?, sleepy:Int?){
		if let c = congestion { self.congestion = c }
		if let r = runny { self.runny = r }
		if let i = itchy { self.itchy = i }
		if let s = sneezy { self.sneezy = s }
		if let s = sleepy { self.sleepy = s }
	}
	
}

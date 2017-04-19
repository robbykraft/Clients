import Firebase

extension Dictionary where Value: Equatable {
	func allKeys(forValue val: Value) -> [Key] {
		return self.filter { $1 == val }.map { $0.0 }
	}
}


class Schedule{
	let VERBOSE = true
	
	static let shared = Schedule()
	
	fileprivate init() { }
	
	// IMPORTANT: (you must do this)
	// to initialize, call "buildSchoolYearCalendar"
	// this will populate the next few variables:
	var todaysLesson:[Lesson]?
	var upcomingLessons:[Date:[Lesson]]?
	var pastLessons:[Date:[Lesson]]?
	
	//these get set in buildSchoolYearCalendar
	var pillarStartTimeStamps:[Int] = [] // store all the pillar's start dates
	var schoolYear:[Date:[[String:Any]]]?
	// Date : [ 0...4 (grade):
	//              { lesson: ______(database pointer)
	//                quote: ______(database pointer)
	//                pillar: _____(pillar number)
	//                behavior: ____(database pointer)
	//              }
	//        ]
	
	
	// unclear if this is getting set:
	var currentPillar:Int? = nil // store current pillar index in pillar array
	
//	func findCurrentPillar(){
//		// find current pillar
//		var thisPillar:Int? = nil
//		var GMTCalendar = Calendar.current
//		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
//		let nowDate:Date = GMTCalendar.startOfDay(for: Date())
//		for i in 0..<pillarStartTimeStamps.count{
//			if(nowDate.timeIntervalSince1970 > pillarStartTimeStamps[i]){
//				thisPillar = i
//			}
//		}
//		self.currentPillar = thisPillar;
//	}

	func sortedFilteredPillarStartDates(pillarTimeStamps:[Int], personalizedOrder:[Int]) -> [[Int:Date]]{
		// input: array of unix time stamps:index=pillar number ([355354, 253563, 352333])
		// output: array of dictionaries [pillar:date], sorted by dates [ [2:Jan 1], [1:Feb 1], ...]
		
		// new!! now also takes into account
		var dates:[Int:Date] = [:]
		for i in 0..<pillarTimeStamps.count{
			let startDate = Date.init(timeIntervalSince1970: Double(pillarTimeStamps[ personalizedOrder[i] ]))
			dates[i] = startDate
		}
		let sortedDates = dates.values.sorted(by: {$0.compare($1) == .orderedAscending})
		var sortedPillars:[[Int:Date]] = []
		
		for i in 0..<sortedDates.count{
			let pillarNumber = dates.allKeys(forValue: sortedDates[i]).first
			sortedPillars.append([pillarNumber!:sortedDates[i]])
		}
		return sortedPillars
	}

	func buildSchoolYearCalendar(client:String, _ completionHandler: @escaping (_ success:Bool,  [Date:[[String:Any]]]? ) -> () ){
		
		FIRDatabase.database().reference().child("schedules/" + client).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			
//			print("schedules/" + client)

			if let scheduleData = snapshot.value as? [String:Any]{
				if let startTimes = scheduleData["pillars"] as? [Int]{
					self.pillarStartTimeStamps = startTimes
					Fire.shared.loadData("users/" + Fire.shared.myUID! + "/pillars", completionHandler: { (pillarArray) in
						var personalOrder = [0, 1, 2, 3, 4, 5, 6]
						if let a = pillarArray as? [Int]{
							personalOrder = a
						}
						let sortedStartDates:[[Int:Date]] = self.sortedFilteredPillarStartDates(pillarTimeStamps: startTimes, personalizedOrder: personalOrder)
						print("Pillar start dates sorted chronologically:")
						print(sortedStartDates)
						
						var calendarDays:[ [String:Any] ] = []
						
						let TWO_MONTHS:TimeInterval = 2678400 * 2
						for i in 0..<sortedStartDates.count{
							var firstDate:Date = sortedStartDates[i].values.first!
							var endDate:Date = firstDate.addingTimeInterval(TWO_MONTHS)
							if(i+1 < sortedStartDates.count){ endDate = sortedStartDates[i+1].values.first! }
							
							// truncate out time, in regards to GMT time
							var GMTCalendar = Calendar.current
							GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
							firstDate = GMTCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: firstDate)!
							endDate = GMTCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDate)!
							
							var dateIterate:Date = firstDate
							var iterator:Int = 0
							var lessonCounter = 0;
							repeat{
								var GMTCalendar = Calendar.current
								GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
								if( !GMTCalendar.isDateInWeekend(dateIterate) ){
									let thisPillar = sortedStartDates[i].keys.first!
									// get the week # of the month, for Lesson Behavior
									var weekNumber:Int = GMTCalendar.component(.weekOfMonth, from: dateIterate)
									// todo: for Character Daily specific purposes, this will sometimes begin at week #2 (if 1st is Friday or Saturday), skipping first entry in database. fix: mod % 5
									weekNumber -= 1
									weekNumber = weekNumber % 5
									calendarDays.append(["date":dateIterate, "pillar":thisPillar, "count":lessonCounter, "week":weekNumber])
									lessonCounter += 1
								}
								iterator += 1
								var deltaDate = DateComponents()
								deltaDate.day = iterator
								dateIterate = (GMTCalendar as NSCalendar).date(byAdding: deltaDate, to: firstDate, options: NSCalendar.Options.matchFirst)!
							}while(dateIterate < endDate)
						}
						//					print("calendar days:")
						//					print(calendarDays)
						
						if let pillarDayGradeLessons = scheduleData["lessons"] as? [Any]{
							var lessonCalendar:[Date:[[String:Any]]] = [:]
							for i in 0..<calendarDays.count{
								let dateIterate:Date = calendarDays[i]["date"] as! Date
								let pillarNumber = calendarDays[i]["pillar"] as! Int
								let orderNumber = calendarDays[i]["count"] as! Int
								let weekCount = calendarDays[i]["week"] as! Int
								var behaviorDatabaseKey:String = ""
								if let allBehaviors = scheduleData["behaviors"] as? [Any]{
									if(pillarNumber < allBehaviors.count){
										if let pillarBehaviors = allBehaviors[pillarNumber] as? [Any]{
											if let behaviorKey = pillarBehaviors[weekCount] as? String{
												behaviorDatabaseKey = behaviorKey
											}
										}
									}
								}
								
								let dayGradeLessons = pillarDayGradeLessons[pillarNumber] as! [Any]
								if(dayGradeLessons.count > orderNumber){
									var gradeLessons = dayGradeLessons[orderNumber] as! [[String:Any]]
									// append the Behavior to the entry
									for i in 0..<gradeLessons.count{
										gradeLessons[i]["behavior"] = behaviorDatabaseKey
									}
									lessonCalendar[dateIterate] = gradeLessons
								}
							}
							//						print("lesson calendar")
							//						print(lessonCalendar)
							self.schoolYear = lessonCalendar
							completionHandler(true, lessonCalendar)
						}
					})
				}
			} else{
				// ALERT:
				// something is wrong with your client's account, would you like to switch back to the default calendar?
			}
		}
	}
	
	func preDownloadAllLessons(_ completionHandler: @escaping (_ success:Bool) -> () ){

//		var todaysLesson:[Lesson]?
//		var upcomingLessons:[Date:[Lesson]]?
//		var pastLessons:[Date:[Lesson]]?
		
		print("pre downloading all lessons")
		
		self.upcomingLessons = [:]
		let nextDates = self.getNextWeekdays(numberOfDays: 5, includeToday: false)
		for day:Date in nextDates{
			if let thisDaysLessonData = self.schoolYear![day]{
				self.upcomingLessons![day] = []
				// create a fixed length array of size # of grade levels (usually 4)
				for _ in 0..<thisDaysLessonData.count {
					self.upcomingLessons![day]?.append(Lesson())
				}
				for i in 0..<thisDaysLessonData.count {
					let thisDaysLesson:Lesson = Lesson()
					thisDaysLesson.setFromDatabase(lessonKey: thisDaysLessonData[i]["lesson"] as! String,
					                               quoteKey: thisDaysLessonData[i]["quote"] as! String,
					                               behaviorKey: thisDaysLessonData[i]["behavior"] as! String,
					                               date: day, { (success, theLesson) in
						self.upcomingLessons![day]?[theLesson.grade!] = theLesson
						print("downloading an upcoming lesson")
					})
				}
			}
		}
		self.pastLessons = [:]
		let prevDates = self.getPreviousWeekdays(numberOfDays: 15, includeToday: false)
		for day:Date in prevDates{
			if let thisDaysLessonData = self.schoolYear![day]{
				self.pastLessons![day] = []
				// create a fixed length array of size # of grade levels (usually 4)
				for _ in 0..<thisDaysLessonData.count {
					self.pastLessons![day]?.append(Lesson())
				}
				for i in 0..<thisDaysLessonData.count {
					let thisDaysLesson:Lesson = Lesson()
					thisDaysLesson.setFromDatabase(lessonKey: thisDaysLessonData[i]["lesson"] as! String,
					                               quoteKey: thisDaysLessonData[i]["quote"] as! String,
					                               behaviorKey: thisDaysLessonData[i]["behavior"] as! String,
					                               date: day, { (success, theLesson) in
						self.pastLessons![day]?[theLesson.grade!] = theLesson
						print("downloading a past lesson")
					})
				}
			}
		}
		var GMTCalendar = Calendar.current
		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		let todaysDate = GMTCalendar.startOfDay(for: Date())
		if let todayLessonData = self.schoolYear![todaysDate]{
			print(todayLessonData)
			self.todaysLesson = []
			for _ in 0..<todayLessonData.count {
				self.todaysLesson?.append(Lesson())
			}
			for i in 0..<todayLessonData.count {
				let thisDaysLesson:Lesson = Lesson()
				thisDaysLesson.setFromDatabase(lessonKey: todayLessonData[i]["lesson"] as! String,
				                               quoteKey: todayLessonData[i]["quote"] as! String,
				                               behaviorKey: todayLessonData[i]["behavior"] as! String,
				                               date: todaysDate, { (success, theLesson) in
					self.todaysLesson?[theLesson.grade!] = theLesson
					print("downloading today's lesson")
					// TODO: this is needing to wait until all 4 grades download before triggering
					completionHandler(true)
				})
			}
		} else{
			print("there is no lesson for today")
			self.todaysLesson = nil;
			completionHandler(true)
		}

	}
	
	func getScheduleForClient(clientName:String, _ completionHandler: @escaping (_ success:Bool,  [String:AnyObject] ) -> () ){
		FIRDatabase.database().reference().child("schedules").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			print("client schedule")
			if snapshot.value is NSNull {
				completionHandler(false, [:])
			} else {
				let clientSchedules = snapshot.value as! [String:AnyObject]
				if clientSchedules[clientName] is NSNull{
					
				} else{
					completionHandler(true, clientSchedules[clientName] as! [String : AnyObject])
				}
			}
		}
	}
	
	// 0: {    // pillar 0
	//      0: [Lesson, Lesson, Lesson]   // grade 0
	//      1: [Lesson, Lesson, Lesson]   // grade 1
	//      ...
	func sortLessonByPillarAndGrade(_ lessons:[Lesson]) -> [Int:[Int:[Lesson]]]{
		var dictionary:[Int:[Int:[Lesson]]] = [:]
		// initialize the dictionary
		for i in 0..<6{
			var gradeEntry:[Int:[Lesson]] = [:]
			for j in 0..<4{
				gradeEntry[j] = []
			}
			dictionary[i] = gradeEntry
		}
		// now we have an initialized dictionary
		for lesson in lessons{
			if(lesson.grade != nil && lesson.pillar != nil){
				dictionary[lesson.pillar!]![lesson.grade!]?.append(lesson)
			}
		}
		return dictionary
	}

	// consider using:
//			if(Calendar.current.isDate(date, inSameDayAs: key)){

	
	// TODO: This is GMT timezone, it will get day after today if it's late enough in the day
	func getNextWeekdays(numberOfDays:Int, includeToday:Bool)->[Date]{
		if numberOfDays <= 0 { return [] }

		// includes today only includes today if it is a weekday!!
		var dateArray:[Date] = []
		var GMTCalendar = Calendar.current
		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		let todaysDate:Date = GMTCalendar.startOfDay(for: Date())
		
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = 1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (GMTCalendar as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = GMTCalendar.component(.weekday, from: date)
			
			switch (weekday) {
			case 2, 3, 4, 5, 6:
				dateArray.append(date);
				break;
			default: break;
			}
			dayIncrement += 1
		}
		return dateArray
	}
	
	func getPreviousWeekdays(numberOfDays:Int, includeToday:Bool)->[Date]{
		if numberOfDays <= 0 { return [] }
		
		// includes today only includes today if it is a weekday!!
		var dateArray:[Date] = []
		var GMTCalendar = Calendar.current
		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		let todaysDate:Date = GMTCalendar.startOfDay(for: Date())
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = -1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (GMTCalendar as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = GMTCalendar.component(.weekday, from: date)
			
			switch (weekday) {
			case 2, 3, 4, 5, 6:
				dateArray.append(date);
				break;
			default: break;
			}
			dayIncrement -= 1
		}
		return dateArray
	}
	
	func getPreviousWeekdaysChronological(numberOfDays:Int, includeToday:Bool)->[Date]{
		if numberOfDays <= 0 { return [] }
		
		// includes today only includes today if it is a weekday!!
		var dateArray:[Date] = []
		var GMTCalendar = Calendar.current
		GMTCalendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
		let todaysDate:Date = GMTCalendar.startOfDay(for: Date())
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = -1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (GMTCalendar as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = GMTCalendar.component(.weekday, from: date)
			
			switch (weekday) {
			case 2, 3, 4, 5, 6:
				dateArray.insert(date, at: 0)
				break;
			default: break;
			}
			dayIncrement -= 1
		}
		return dateArray
	}

	
	
//	func findCurrentPillar() {
//		var date:Date = firstDate
//		while(date.isLessThanDate(endDate)){
//			
//			// find current pillar
//			var thisPillar:Int? = nil
//			for i in 0..<self.pillarStartTimeStamps.count{
//				if(date.timeIntervalSince1970 > self.pillarStartTimeStamps[i]){
//					thisPillar = i
//				}
//			}
//			
//			if( !Calendar.current.isDateInWeekend(date) ){
//				if(thisPillar != nil){
//					let entry = ["date":date, "pillar":thisPillar!, "count":pillarCounts[thisPillar!] ] as [String : Any]
//					array.append(entry as [String : AnyObject])
//					// increment pillar count
//					pillarCounts[thisPillar!] += 1
//				}
//			}
//			// increment day
//			var deltaDate = DateComponents()
//			deltaDate.day = 1
//			date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: date, options: NSCalendar.Options.matchFirst)!
//		}
//		
//	}
	
	
//	func dateExistsInArray(date:Date, dateArray:[Date]) -> Bool{
//		for d in dateArray{
//			if(Int(d.timeIntervalSince1970) == Int(date.timeIntervalSince1970)){
//				return true
//			}
//		}
//		return false
//	}
//	

}

import Firebase

class Character{
	static let shared = Character()
	
	private init() { }

//	var lessons:[String:AnyObject]?  // lessons data
	let pillarNames = ["trustworthiness", "respect", "responsibility", "fairness", "caring", "citizenship"]
	let gradeNames = ["K-2nd", "3rd-5th", "6th-8th", "9th-12th"]
	
	let SchoolNames = ["Holy Cross",
	                   "Our Mother of Sorrows/ St. Ignatius of Loyola",
	                   "St. Barnabas",
	                   "St. Cyril of Alexandria",
	                   "St. Frances Cabrini",
	                   "St. Gabriel",
	                   "St. Helena Incarnation",
	                   "St. Malachy",
	                   "St. Martin de Porres",
	                   "St. Martin of Tours",
	                   "St. Raymond of Penafort",
	                   "St. Rose of Lima",
	                   "The DePaul Catholic School",
	                   "St. Thomas Aquinas",
	                   "St. Veronica"]
	
	// each entry is an array of 4 lessons, one of each grade level
	var todaysLesson:[Lesson]?
	var upcomingLessons:[NSDate:[Lesson]]?
	var pastLessons:[NSDate:[Lesson]]?
	
	
	
	func getMyScore(completionHandler: ( [NSDate:Int]? ) -> () ) {
		Fire.shared.getUser { (uid, userData) in
			if(userData != nil){

				var challengeDictionary:[NSDate:Int] = [:]

				// gather all challenges user has visited
				var challenges:[String:[Bool]]? = userData!["challenges"] as! [String:[Bool]]?
				if(challenges == nil){
					challenges = [:]
				}
				let lessonKeysCompleted:[String] = Array((challenges!).keys)
				
				// all the dates
				let dateLessonPairs = self.allLoadedDateLessonPairs()

				for date in Array(dateLessonPairs.keys){
					// iterate over all the dates
					challengeDictionary[date] = 0

					// though, if user completed one fill it in
					let lessonKeys:[String] = dateLessonPairs[date]!
					for key in lessonKeys{
						if(lessonKeysCompleted.contains(key)){
							let boolArray = challenges![key]
							var count:Int = 0
							if(boolArray != nil){
								for entry in boolArray!{
									if(entry){
										count += 1
									}
								}
							}
							challengeDictionary[date] = challengeDictionary[date]! + count
						}
					}
				}
				completionHandler(challengeDictionary)
			}
		}
	}
	
	func allLoadedDateLessonPairs() -> [ NSDate:[String] ] {  // [String]: is array of lesson keys in database
		var dates:[ NSDate:[String] ] = [:]
		if(self.upcomingLessons != nil){
			let upcomingDates:[NSDate] = Array( (upcomingLessons?.keys)! )
			for date in upcomingDates{
				let lessons:[Lesson]? = upcomingLessons![date]
				if(lessons != nil){
					var keyArray:[String] = []
					for lesson in lessons!{
						keyArray.append(lesson.key!)
					}
					dates[date] = keyArray
				}
			}
		}
		if(self.pastLessons != nil){
			let pastDates:[NSDate] = Array( (pastLessons?.keys)! )
			for date in pastDates{
				let lessons:[Lesson]? = pastLessons![date]
				if(lessons != nil){
					var keyArray:[String] = []
					for lesson in lessons!{
						keyArray.append(lesson.key!)
					}
					dates[date] = keyArray
				}
			}
		}
		return dates
	}
	
	
	// MASSIVE AMOUNT OF CODE FOR GETTING LESSONS
	
	func lessonsWithFilter(gradeLevels:[Int]) -> (Lesson?, [Lesson]){
		var today:Lesson? = nil
		if(todaysLesson != nil){
			for lesson in todaysLesson!{
				if (gradeLevels.contains(lesson.grade!)){
					today = lesson
				}
			}
		}
		var allLessons:[Lesson] = []
		if(pastLessons != nil){
			let past:[NSDate:[Lesson]] = pastLessons!
			var keys:[NSDate] = Array(past.keys)
			keys.sortInPlace({ $0.compare($1) == NSComparisonResult.OrderedAscending })
			for key in keys{
				let daysLessons = pastLessons![key]
				if(daysLessons != nil){
					for lesson in daysLessons!{
						if(gradeLevels.contains(lesson.grade!)){
							allLessons.append(lesson)
						}
					}
				}
			}
		}
		if(upcomingLessons != nil){
			let upcoming:[NSDate:[Lesson]] = upcomingLessons!
			var keys:[NSDate] = Array(upcoming.keys)
			keys.sortInPlace({ $0.compare($1) == NSComparisonResult.OrderedAscending })
			for key in keys{
				let daysLessons = upcomingLessons![key]
				if(daysLessons != nil){
					for lesson in daysLessons!{
						if(gradeLevels.contains(lesson.grade!)){
							allLessons.append(lesson)
						}
					}
				}
			}
		}
		return (today,allLessons)
	}

	
	func downloadAndPrepareLessons(completionHandler: (success:Bool) -> () ) {
		FIRDatabase.database().reference().child("lessons").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(success: false)
			} else {
				// SUCCESS connecting to the database
				let lessonsJSON = snapshot.value as? [String:AnyObject]

				self.getScheduleArray({ (scheduleArray) in

					let lessonArray:[Lesson] = self.lessonsFromJSON(lessonsJSON!)
					
					let lessonDictionary = self.sortLessonByPillarAndGrade(lessonArray)

					let lessonSchedule = self.makeLessonSchedule(lessonDictionary, scheduleArray: scheduleArray)

					self.todaysLesson = self.getTodaysLesson(lessonSchedule)
					self.upcomingLessons = self.getNext5Lessons(lessonSchedule)
					self.pastLessons = self.getLast15Lessons(lessonSchedule)
					
					completionHandler(success: true)
				})
			}
		}
	}
	
	
	// array:
	//  0: (date, pillar, pillar count index)
	//  1: (date, pillar, pillar count index)
	func getScheduleArray(completionHandler: ( [ [String:AnyObject] ] ) -> () ) {
		FIRDatabase.database().reference().child("schedule/pillar").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {

			} else {
				var array:[ [String:AnyObject] ] = []
				let ONE_MONTH:NSTimeInterval = 2678400
				let startTimes:[Double] = snapshot.value as! [Double]
				let firstDate:NSDate = NSDate(timeIntervalSince1970: startTimes[0])
				let endDate:NSDate = NSDate(timeInterval: ONE_MONTH, sinceDate: NSDate(timeIntervalSince1970: startTimes.last!))
				
				var pillarCounts:[Int] = []
				for _ in startTimes{
					pillarCounts.append(0)
				}
				
				var date:NSDate = firstDate
				while(date.isLessThanDate(endDate)){
					
					// find current pillar
					var thisPillar:Int? = nil
					for i in 0..<startTimes.count{
						if(date.timeIntervalSince1970 > startTimes[i]){
							thisPillar = i
						}
					}
					
					if( !NSCalendar.currentCalendar().isDateInWeekend(date) ){
						if(thisPillar != nil){
							let entry = ["date":date, "pillar":thisPillar!, "count":pillarCounts[thisPillar!] ]
							array.append(entry)
							// increment pillar count
							pillarCounts[thisPillar!] += 1
						}
					}
					// increment day
					let deltaDate = NSDateComponents()
					deltaDate.day = 1
					date = NSCalendar.currentCalendar().dateByAddingComponents(deltaDate, toDate: date, options: NSCalendarOptions.MatchFirst)!
				}
				completionHandler(array)
			}
		}
	}
	

	
	func lessonsFromJSON(lessonsJSON:[String:AnyObject]) -> [Lesson]{
		var lessonArray:Array<Lesson> = []
		let keyArray:[String] = Array(lessonsJSON.keys)
		for key in keyArray {
			let object:[String:AnyObject] = lessonsJSON[key] as! [String:AnyObject]
			let lesson:Lesson = Lesson.init(key: key, dictionary: object)
			lessonArray.append(lesson)
		}
		return lessonArray
	}
	
	
	
	// 0: {    // pillar 0
	//      0: [Lesson, Lesson, Lesson]   // grade 0
	//      1: [Lesson, Lesson, Lesson]   // grade 1
	//      ...
	func sortLessonByPillarAndGrade(lessons:[Lesson]) -> [Int:[Int:[Lesson]]]{
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


	// Date: [Lesson, Lesson, Lesson]    // each with different grade numbers
	func makeLessonSchedule(lessonDictionary:[Int:[Int:[Lesson]]], scheduleArray:[[String:AnyObject]]  )->[NSDate:[Lesson]]{
		var dateDictionary:[NSDate:[Lesson]] = [:]
		
		for entry in scheduleArray {
			let date:NSDate = entry["date"] as! NSDate
			let pillar:Int = entry["pillar"] as! Int
			let count:Int = entry["count"] as! Int

			if(dateDictionary[date] == nil){
				dateDictionary[date] = []
			}

			let gradeArrays = lessonDictionary[pillar]!
			for i in 0..<4{
				let thisGradeArray = gradeArrays[i]
				if(thisGradeArray != nil && thisGradeArray?.count > count){
					let thisSortedGradeArray = thisGradeArray!.sort({ $0.order < $1.order })
					let thisGradeObject:Lesson? = thisSortedGradeArray[count]
					if(thisGradeObject != nil){
						thisGradeObject?.date = date
						dateDictionary[date]?.append(thisGradeObject!)
					}
				}
			}
		}
		return dateDictionary
	}
	
	func getTodaysLesson(lessonSchedule:[NSDate:[Lesson]])->[Lesson]?{
		let keys = lessonSchedule.keys
		
		let date:NSDate = NSDate()
		
		for key in keys{
			if(NSCalendar.currentCalendar().isDate(date, inSameDayAsDate: key)){
				return lessonSchedule[key]
			}
		}
		return nil
	}
	
	
	func getNext5Lessons(lessonSchedule:[NSDate:[Lesson]])->[NSDate:[Lesson]]{
		var fiveLessons:[NSDate:[Lesson]] = [:]
		let keys = lessonSchedule.keys
		
		var date:NSDate = NSDate()
		var iterations:Int = 0
		
		while(fiveLessons.count < 5 && iterations < 1000){
			for key in keys{
				if(NSCalendar.currentCalendar().isDate(date, inSameDayAsDate: key)){
					fiveLessons[key] = lessonSchedule[key]
				}
			}
			
			let deltaDate = NSDateComponents()
			deltaDate.day = 1
			date = NSCalendar.currentCalendar().dateByAddingComponents(deltaDate, toDate: date, options: NSCalendarOptions.MatchFirst)!
			iterations += 1
		}
		return fiveLessons
	}
	
	func getLast15Lessons(lessonSchedule:[NSDate:[Lesson]])->[NSDate:[Lesson]]{
		var fifteenLessons:[NSDate:[Lesson]] = [:]
		let keys = lessonSchedule.keys
		
		var date:NSDate = NSDate()
		var iterations:Int = 0
		
		while(fifteenLessons.count < 15 && iterations < 1000){
			for key in keys{
				if(NSCalendar.currentCalendar().isDate(date, inSameDayAsDate: key)){
					fifteenLessons[key] = lessonSchedule[key]
				}
			}
			
			let deltaDate = NSDateComponents()
			deltaDate.day = -1
			date = NSCalendar.currentCalendar().dateByAddingComponents(deltaDate, toDate: date, options: NSCalendarOptions.MatchFirst)!
			iterations += 1
		}
		return fifteenLessons
	}
	

	
	func filterLessonsByAudience(lessons:[Lesson], pillars:[Int], gradeLevels:[Int])->Array<Lesson>?{
		var filteredArray:[Lesson] = []
		for lesson in lessons{
			if(pillars.contains(lesson.pillar!) && gradeLevels.contains(lesson.grade!)){
				filteredArray.append(lesson)
			}
		}
		return filteredArray
	}
	
	
}
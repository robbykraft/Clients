import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Character{
	let VERBOSE = true
	
	static let shared = Character()
	
	fileprivate init() { }

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
	var upcomingLessons:[Date:[Lesson]]?
	var pastLessons:[Date:[Lesson]]?
	
	var pillarStartTimeStamps:[Double] = [] // store all the pillar's start dates
	var currentPillar:Int? = nil // store current pillar index in pillar array
	
	func findCurrentPillar(){
		// find current pillar
		var thisPillar:Int? = nil
		let nowDate:Date = Date()
		for i in 0..<pillarStartTimeStamps.count{
			if(nowDate.timeIntervalSince1970 > pillarStartTimeStamps[i]){
				thisPillar = i
			}
		}
		self.currentPillar = thisPillar;
	}
	
	func getMyGradeLevels(_ completionHandler: @escaping ( Bool, [Int] ) -> ()){
		Fire.shared.getUser { (uid, data) in
			if let userData = data{
				if let userGrades = userData["grade"] as? [Int]{
					// grades okay
					completionHandler(true, userGrades)
				} else{
					// user has not been assigned a grade yet
					let userGrades = [0,1,2,3]
					Fire.shared.updateUserWithKeyAndValue("grade", value: userGrades as AnyObject, completionHandler: { (success) in
						// NOW grades okay
						completionHandler(true, userGrades)
					})
				}
			} else{
				// nah, something wrong with getting this user...
				completionHandler(false, [])
			}
		}
	}
	
	func getMyClientID(_ completionHandler: @escaping ( Bool, String ) -> ()){
		Fire.shared.getUser { (uid, data) in
			if let userData = data{
				if let userClient = userData["client"] as? String{
					// we have a client
					completionHandler(true, userClient)
				} else{
					// user has not been assigned a grade yet
					let userClient = "0000"
					Fire.shared.updateUserWithKeyAndValue("client", value: userClient as AnyObject, completionHandler: { (success) in
						// NOW client okay
						completionHandler(true, userClient)
					})
				}
			} else{
				// nah, something wrong with getting this user...
				completionHandler(false, "")
			}
		}
	}
	
	// each entry for a Date has an array of array of Bool
	// inner array is always the [Bool Bool Bool], 1 2 3 challenge completion
	// outer array is if they are teachers of multiple grades, multiple challenges per day
	func getMyScore(_ completionHandler: @escaping ( [Date:[[Bool]]]? ) -> () ) {
		Fire.shared.getUser { (uid, userData) in
			if(userData != nil){
				
				var challengeDictionary:[Date:[[Bool]]] = [:]

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
					if(challengeDictionary[date] == nil){
						challengeDictionary[date] = []
					}

					// though, if user completed one fill it in
					let lessonKeys:[String] = dateLessonPairs[date]!
					for key in lessonKeys{
						if(lessonKeysCompleted.contains(key)){
							let boolArray = challenges![key]
//							var count:Int = 0
							if(boolArray != nil){
								(challengeDictionary[date])?.append(boolArray!)
//								for entry in boolArray!{
//									if(entry){
//										count += 1
//									}
//								}
							}
//							challengeDictionary[date] = challengeDictionary[date]! + count
						}
					}
				}
				completionHandler(challengeDictionary)
			}
		}
	}
	
	func allLoadedDateLessonPairs() -> [ Date:[String] ] {  // [String]: is array of lesson keys in database
		var dates:[ Date:[String] ] = [:]
		if(self.upcomingLessons != nil){
			let upcomingDates:[Date] = Array( (upcomingLessons?.keys)! )
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
			let pastDates:[Date] = Array( (pastLessons?.keys)! )
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
	
	func lessonsWithFilter(_ gradeLevels:[Int]) -> (Lesson?, [Lesson]){
		var today:Lesson? = nil
		if(todaysLesson != nil){
			for lesson in todaysLesson!{
				if (gradeLevels.contains(lesson.grade!)){
					today = lesson
				}
			}
		}
		var pastLessonKeys:[Date] = [] // this is to check for duplicates in upcoming lessons
		var allLessons:[Lesson] = []
		if(pastLessons != nil){
			let past:[Date:[Lesson]] = pastLessons!
			var keys:[Date] = Array(past.keys)
			keys.sort(by: { $0.compare($1) == ComparisonResult.orderedAscending })
			pastLessonKeys = keys
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
			let upcoming:[Date:[Lesson]] = upcomingLessons!
			var keys:[Date] = Array(upcoming.keys)
			keys.sort(by: { $0.compare($1) == ComparisonResult.orderedAscending })
			for key in keys{
				let daysLessons = upcomingLessons![key]
				if(daysLessons != nil){
					for lesson in daysLessons!{
						if(gradeLevels.contains(lesson.grade!)){
							if(!dateExistsInArray(date: key, dateArray: pastLessonKeys)){
								allLessons.append(lesson)
							}
						}
					}
				}
			}
		}
		return (today,allLessons)
	}
	
	func dateExistsInArray(date:Date, dateArray:[Date]) -> Bool{
		for d in dateArray{
			if(Int(d.timeIntervalSince1970) == Int(date.timeIntervalSince1970)){
				return true
			}
		}
		return false
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

	
	func downloadAndPrepareLessons(_ completionHandler: @escaping (_ success:Bool) -> () ) {
		if(self.VERBOSE){ print("download and prepare lessons") }
		
		FIRDatabase.database().reference().child("lessons").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(false)
			} else {
				// SUCCESS connecting to the database
				let lessonsJSON = snapshot.value as? [String:AnyObject]
				self.getScheduleForClient(clientName: "0000", { (success) in
					
				})

//				self.getScheduleArray({ (scheduleArray) in
//
//					let lessonArray:[Lesson] = self.lessonsFromJSON(lessonsJSON!)
//					
//					let lessonDictionary = self.sortLessonByPillarAndGrade(lessonArray)
//
//					let lessonSchedule = self.makeLessonSchedule(lessonDictionary, scheduleArray: scheduleArray)
//
//					self.todaysLesson = self.getTodaysLesson(lessonSchedule)
//					self.upcomingLessons = self.getNext5Lessons(lessonSchedule)
//					self.pastLessons = self.getLast15Lessons(lessonSchedule)
//					
//					self.findCurrentPillar()
//					
//					completionHandler(true)
//				})
			}
		}
	}
	
	
	// array:
	//  0: (date, pillar, pillar count index)
	//  1: (date, pillar, pillar count index)
	func getScheduleArray(_ completionHandler: @escaping ( [ [String:AnyObject] ] ) -> () ) {
		FIRDatabase.database().reference().child("schedules/0000/pillar").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				
			} else {
				if(self.VERBOSE){ print("first batch of schedule data") }
				if(self.VERBOSE){ print(snapshot.value) }
				
				var array:[ [String:AnyObject] ] = []
				let ONE_MONTH:TimeInterval = 2678400
				self.pillarStartTimeStamps = snapshot.value as! [Double]
				let firstDate:Date = Date(timeIntervalSince1970: self.pillarStartTimeStamps[0])
				let endDate:Date = Date(timeInterval: ONE_MONTH, since: Date(timeIntervalSince1970: self.pillarStartTimeStamps.last!))
				
				var pillarCounts:[Int] = []
				for _ in self.pillarStartTimeStamps{
					pillarCounts.append(0)
				}
				
				var date:Date = firstDate
				while(date.isLessThanDate(endDate)){
					
					// find current pillar
					var thisPillar:Int? = nil
					for i in 0..<self.pillarStartTimeStamps.count{
						if(date.timeIntervalSince1970 > self.pillarStartTimeStamps[i]){
							thisPillar = i
						}
					}
					
					if( !Calendar.current.isDateInWeekend(date) ){
						if(thisPillar != nil){
							let entry = ["date":date, "pillar":thisPillar!, "count":pillarCounts[thisPillar!] ] as [String : Any]
							array.append(entry as [String : AnyObject])
							// increment pillar count
							pillarCounts[thisPillar!] += 1
						}
					}
					// increment day
					var deltaDate = DateComponents()
					deltaDate.day = 1
					date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: date, options: NSCalendar.Options.matchFirst)!
				}
				completionHandler(array)
			}
		}
	}
	

	
	func lessonsFromJSON(_ lessonsJSON:[String:AnyObject]) -> [Lesson]{
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


	// Date: [Lesson, Lesson, Lesson]    // each with different grade numbers
	func makeLessonSchedule(_ lessonDictionary:[Int:[Int:[Lesson]]], scheduleArray:[[String:AnyObject]]  )->[Date:[Lesson]]{
		var dateDictionary:[Date:[Lesson]] = [:]
		
		for entry in scheduleArray {
			let date:Date = entry["date"] as! Date
			let pillar:Int = entry["pillar"] as! Int
			let count:Int = entry["count"] as! Int

			if(dateDictionary[date] == nil){
				dateDictionary[date] = []
			}

			let gradeArrays = lessonDictionary[pillar]!
			for i in 0..<4{
				let thisGradeArray = gradeArrays[i]
				if(thisGradeArray != nil && thisGradeArray?.count > count){
					let thisSortedGradeArray = thisGradeArray!.sorted(by: { $0.order < $1.order })
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
	
	func getTodaysLesson(_ lessonSchedule:[Date:[Lesson]])->[Lesson]?{
		let keys = lessonSchedule.keys
		
		let date:Date = Date()
		
		for key in keys{
			if(Calendar.current.isDate(date, inSameDayAs: key)){
				return lessonSchedule[key]
			}
		}
		return nil
	}
	
	
	func getNext5Lessons(_ lessonSchedule:[Date:[Lesson]])->[Date:[Lesson]]{
		var fiveLessons:[Date:[Lesson]] = [:]
		let keys = lessonSchedule.keys
		
		var date:Date = Date()
		var iterations:Int = 0
		
		while(fiveLessons.count < 5 && iterations < 1000){
			for key in keys{
				if(Calendar.current.isDate(date, inSameDayAs: key)){
					fiveLessons[key] = lessonSchedule[key]
				}
			}
			
			var deltaDate = DateComponents()
			deltaDate.day = 1
			date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: date, options: NSCalendar.Options.matchFirst)!
			iterations += 1
		}
		return fiveLessons
	}
	
	func getLast15Lessons(_ lessonSchedule:[Date:[Lesson]])->[Date:[Lesson]]{
		var fifteenLessons:[Date:[Lesson]] = [:]
		let keys = lessonSchedule.keys
		
		var date:Date = Date()
		var iterations:Int = 0
		
		while(fifteenLessons.count < 15 && iterations < 1000){
			for key in keys{
				if(Calendar.current.isDate(date, inSameDayAs: key)){
					fifteenLessons[key] = lessonSchedule[key]
				}
			}
			
			var deltaDate = DateComponents()
			deltaDate.day = -1
			date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: date, options: NSCalendar.Options.matchFirst)!
			iterations += 1
		}
		return fifteenLessons
	}
	

	
	func filterLessonsByAudience(_ lessons:[Lesson], pillars:[Int], gradeLevels:[Int])->Array<Lesson>?{
		var filteredArray:[Lesson] = []
		for lesson in lessons{
			if(pillars.contains(lesson.pillar!) && gradeLevels.contains(lesson.grade!)){
				filteredArray.append(lesson)
			}
		}
		return filteredArray
	}
	
	
}

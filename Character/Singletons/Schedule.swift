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
	
	var schoolYear:[Date:[[String:Any]]]?
	// Date : [ 0...4 (grade):
	//              { Lesson: ______(database pointer)
	//                Quote: ______(database pointer)
	//                Pillar: _____(pillar number)
	//                Behavior: ____(database pointer)
	//              }
	//        ]
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

	func sortedPillarStartDates(pillarTimeStamps:[Int]) -> [[Int:Date]]{
		// input: array of unix time stamps:index=pillar number ([355354, 253563, 352333])
		// output: array of dictionaries [pillar:date], sorted by dates [ [2:Jan 1], [1:Feb 1], ...]
		var dates:[Int:Date] = [:]
		for i in 0..<pillarTimeStamps.count{
			let startDate = Date.init(timeIntervalSince1970: Double(pillarTimeStamps[i]))
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
					let sortedStartDates:[[Int:Date]] = self.sortedPillarStartDates(pillarTimeStamps: startTimes)
					print(sortedStartDates)
					
					var calendarDays:[ [String:Any] ] = []
					
					let TWO_MONTHS:TimeInterval = 2678400 * 2
					for i in 0..<sortedStartDates.count{
						let firstDate:Date = sortedStartDates[i].values.first!
						var endDate:Date = firstDate.addingTimeInterval(TWO_MONTHS)
						if(i+1 < sortedStartDates.count){ endDate = sortedStartDates[i+1].values.first! }
						
						var dateIterate:Date = firstDate
						var iterator:Int = 0
						var lessonCounter = 0;
						repeat{
							if( !Calendar.current.isDateInWeekend(dateIterate) ){
								let thisPillar = sortedStartDates[i].keys.first!
								calendarDays.append(["date":dateIterate, "pillar":thisPillar, "count":lessonCounter])
								lessonCounter += 1
							}
							iterator += 1
							var deltaDate = DateComponents()
							deltaDate.day = iterator
							dateIterate = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: firstDate, options: NSCalendar.Options.matchFirst)!

						}while(dateIterate < endDate)
					}

					if let pillarDayGradeLessons = scheduleData["lessons"] as? [Any]{
						var lessonCalendar:[Date:[[String:Any]]] = [:]
						for i in 0..<calendarDays.count{
							let dateIterate:Date = calendarDays[i]["date"] as! Date
							let pillarNumber = calendarDays[i]["pillar"] as! Int
							let orderNumber = calendarDays[i]["count"] as! Int

							let dayGradeLessons = pillarDayGradeLessons[pillarNumber] as! [Any]
							if(dayGradeLessons.count > orderNumber){
								let gradeLessons = dayGradeLessons[orderNumber] as! [[String:Any]]
								lessonCalendar[dateIterate] = gradeLessons;
							}
						}
						completionHandler(true, lessonCalendar)
					}
				}
			} else{
				// ALERT:
				// something is wrong with your client's account, would you like to switch back to the default calendar?
			}
		}
	}
	
	func buildLessonData(_ completionHandler: @escaping (_ success:Bool) -> () ){

//		var todaysLesson:[Lesson]?
//		var upcomingLessons:[Date:[Lesson]]?
//		var pastLessons:[Date:[Lesson]]?
		
		let nextDates = self.getNextWeekdays(numberOfDays: 5, includeToday: false)
		
		print("getting lessons")
		var count = 069;
		for day:Date in nextDates{
			let lessonID = String(count)
			count += 1
			print("lessons/" + lessonID)
			FIRDatabase.database().reference().child("lessons/0" + lessonID).observeSingleEvent(of: .value, with: { (snapshot) in
//				let lessonJSON = snapshot.value as! [String:Any]

				let lesson:Lesson = Lesson.init(key: lessonID, dictionary: snapshot.value as! Dictionary<String, Any>)
				
				
//				let lessonDictionary = self.sortLessonByPillarAndGrade(lessonArray)
//				
//				let lessonSchedule = self.makeLessonSchedule(lessonDictionary, scheduleArray: scheduleArray)
//				
//				self.todaysLesson = self.getTodaysLesson(lessonSchedule)
//				self.upcomingLessons = self.getNext5Lessons(lessonSchedule)
//				self.pastLessons = self.getLast15Lessons(lessonSchedule)
//				
//				self.findCurrentPillar()
//				
				
				print(lesson)
				completionHandler(true)

			})
		}
	}
	
	
//	func allLoadedDateLessonPairs() -> [ Date:[String] ] {  // [String]: is array of lesson keys in database
//		var dates:[ Date:[String] ] = [:]
//		if(self.upcomingLessons != nil){
//			let upcomingDates:[Date] = Array( (upcomingLessons?.keys)! )
//			for date in upcomingDates{
//				let lessons:[Lesson]? = upcomingLessons![date]
//				if(lessons != nil){
//					var keyArray:[String] = []
//					for lesson in lessons!{
//						keyArray.append(lesson.key!)
//					}
//					dates[date] = keyArray
//				}
//			}
//		}
//		if(self.pastLessons != nil){
//			let pastDates:[Date] = Array( (pastLessons?.keys)! )
//			for date in pastDates{
//				let lessons:[Lesson]? = pastLessons![date]
//				if(lessons != nil){
//					var keyArray:[String] = []
//					for lesson in lessons!{
//						keyArray.append(lesson.key!)
//					}
//					dates[date] = keyArray
//				}
//			}
//		}
//		return dates
//	}
	
	
	// MASSIVE AMOUNT OF CODE FOR GETTING LESSONS
	
//	func lessonsWithFilter(_ gradeLevels:[Int]) -> (Lesson?, [Lesson]){
//		var today:Lesson? = nil
//		if(todaysLesson != nil){
//			for lesson in todaysLesson!{
//				if (gradeLevels.contains(lesson.grade!)){
//					today = lesson
//				}
//			}
//		}
//		var pastLessonKeys:[Date] = [] // this is to check for duplicates in upcoming lessons
//		var allLessons:[Lesson] = []
//		if(pastLessons != nil){
//			let past:[Date:[Lesson]] = pastLessons!
//			var keys:[Date] = Array(past.keys)
//			keys.sort(by: { $0.compare($1) == ComparisonResult.orderedAscending })
//			pastLessonKeys = keys
//			for key in keys{
//				let daysLessons = pastLessons![key]
//				if(daysLessons != nil){
//					for lesson in daysLessons!{
//						if(gradeLevels.contains(lesson.grade!)){
//							allLessons.append(lesson)
//						}
//					}
//				}
//			}
//		}
//		if(upcomingLessons != nil){
//			let upcoming:[Date:[Lesson]] = upcomingLessons!
//			var keys:[Date] = Array(upcoming.keys)
//			keys.sort(by: { $0.compare($1) == ComparisonResult.orderedAscending })
//			for key in keys{
//				let daysLessons = upcomingLessons![key]
//				if(daysLessons != nil){
//					for lesson in daysLessons!{
//						if(gradeLevels.contains(lesson.grade!)){
//							if(!dateExistsInArray(date: key, dateArray: pastLessonKeys)){
//								allLessons.append(lesson)
//							}
//						}
//					}
//				}
//			}
//		}
//		return (today,allLessons)
//	}
	
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
//				let lessonsJSON = snapshot.value as? [String:AnyObject]
//				self.getScheduleForClient(clientName: "0000", { (success) in
//					
//				})

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
				if(self.VERBOSE){ print(snapshot.value!) }
				
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
	

	func lessonsFromJSON(_ lessonsJSON:[String:Any]) -> [Lesson]{
		var lessonArray:Array<Lesson> = []
		let keyArray:[String] = Array(lessonsJSON.keys)
		for key in keyArray {
			let object:[String:Any] = lessonsJSON[key] as! [String:Any]
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
	
	
	// TODO: This is GMT timezone, it will get day after today if it's late enough in the day
	func getNextWeekdays(numberOfDays:Int, includeToday:Bool)->[Date]{
		if numberOfDays <= 0 { return [] }

		// includes today only includes today if it is a weekday!!
		var dateArray:[Date] = []
		let todaysDate:Date = Date()
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = 1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = Calendar.current.component(.weekday, from: date)
			
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
		let todaysDate:Date = Date()
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = -1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = Calendar.current.component(.weekday, from: date)
			
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
		let todaysDate:Date = Date()
		var dayIncrement:Int = 0
		if !includeToday { dayIncrement = -1 }
		
		while(dateArray.count < numberOfDays){
			var deltaDate = DateComponents()
			deltaDate.day = dayIncrement
			
			let date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: todaysDate, options: NSCalendar.Options.matchFirst)!
			let weekday = Calendar.current.component(.weekday, from: date)
			
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

}

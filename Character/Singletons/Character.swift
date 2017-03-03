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

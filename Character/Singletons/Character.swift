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
	
	var myGradeLevel:[Int] = [0]

//	var lessons:[String:AnyObject]?  // lessons data
	let pillarNames = ["trustworthiness", "respect", "responsibility", "fairness", "caring", "citizenship", "introduction"]
	let gradeNames = ["K-2nd", "3rd-5th", "6th-8th", "9th-12th"]
	
	var clientID = "default"
	
	func boot(_ completionHandler: @escaping (Bool, String?) -> ()){ // success, clientID, gradeLevels
		self.getMyGradeLevels { (successGrades, gradeLevels) in
			self.getMyClientID({ (successClient, client) in
				if(!successGrades){
					completionHandler(false, "problem loading this user's grade levels")
				} else if(!successClient){
					completionHandler(false, "problem loading this user's client id")
				}
				// SUCCESS: we have grade levels and client
				Schedule.shared.buildSchoolYearCalendar(client: client) { (successBuildYear, schoolYear) in
					if(!successBuildYear){
						completionHandler(false, "problem assembling school year calendar")
					} else{
//						print(schoolYear!)
						Schedule.shared.preDownloadAllLessons({ (successLesson) in
							print("got lessons, today's lesson:")
							if(Schedule.shared.todaysLesson == nil){
								// no lesson today
								completionHandler(true, nil)
							} else{
								completionHandler(true, nil)
							}
//							self.reloadLessons(gradeLevels)
//							Character.shared.downloadAndPrepareLessons({ (success) in
//								self.setLoadingScreen(visible: true)
//								self.reloadLessons(gradeLevels)
//							})
						})
					}
				}
			})
		}
	}

	fileprivate func getMyGradeLevels(_ completionHandler: @escaping ( Bool, [Int] ) -> ()){
		Fire.shared.getUser { (uid, data) in
			if let userData = data{
				if let userGrades = userData["grade"] as? [Int]{
					// grades okay
					self.myGradeLevel = userGrades
					completionHandler(true, userGrades)
				} else{
					// user has not been assigned a grade yet
					let userGrades = [0,1,2,3]
					Fire.shared.updateUserWithKeyAndValue("grade", value: userGrades as AnyObject, completionHandler: { (success) in
						// NOW grades okay
						self.myGradeLevel = userGrades
						completionHandler(true, userGrades)
					})
				}
			} else{
				// nah, something wrong with getting this user...
				completionHandler(false, [])
			}
		}
	}
	
	fileprivate func getMyClientID(_ completionHandler: @escaping ( Bool, String ) -> ()){
		Fire.shared.getUser { (uid, data) in
			if let userData = data{
				if let userClient = userData["client"] as? String{
					// we have a client
					completionHandler(true, userClient)
				} else{
					// user has not been assigned a grade yet
					let userClient = "default"
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
	
	func updateChallengeCompletion(_ databaseObject:String, didComplete:Bool, completionHandler: ( ( Bool ) -> () )! ){
		Fire.shared.updateUserWithKeyAndValue("challenges/" + databaseObject, value: didComplete as AnyObject, completionHandler: { (success) in
			if completionHandler != nil{
				completionHandler(true)
			}
		})
	}

	
	// each entry for a Date has an array of array of Bool
	// inner array is always the [Bool Bool Bool], 1 2 3 challenge completion
	// outer array is if they are teachers of multiple grades, multiple challenges per day
	func getMyScore(_ completionHandler: @escaping ( [Date:[[Bool]]]? ) -> () ) {
		Fire.shared.getUser { (uid, userData) in
			if(userData != nil){
				
				let challengeDictionary:[Date:[[Bool]]] = [:]

				// gather all challenges user has visited
				var challenges:[String:[Bool]]? = userData!["challenges"] as! [String:[Bool]]?
				if(challenges == nil){
					challenges = [:]
				}
//				let lessonKeysCompleted:[String] = Array((challenges!).keys)
				
				// all the dates
//				let dateLessonPairs = self.allLoadedDateLessonPairs()
//
//				for date in Array(dateLessonPairs.keys){
//					// iterate over all the dates
//					if(challengeDictionary[date] == nil){
//						challengeDictionary[date] = []
//					}
//
//					// though, if user completed one fill it in
//					let lessonKeys:[String] = dateLessonPairs[date]!
//					for key in lessonKeys{
//						if(lessonKeysCompleted.contains(key)){
//							let boolArray = challenges![key]
////							var count:Int = 0
//							if(boolArray != nil){
//								(challengeDictionary[date])?.append(boolArray!)
////								for entry in boolArray!{
////									if(entry){
////										count += 1
////									}
////								}
//							}
////							challengeDictionary[date] = challengeDictionary[date]! + count
//						}
//					}
//				}
				completionHandler(challengeDictionary)
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

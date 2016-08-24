import Firebase

class Character{
	static let shared = Character()
	
	private init() { }

	var lessons:[String:AnyObject]?  // lessons data
	let pillarNames = ["trustworthiness", "respect", "responsibility", "fairness", "caring", "citizenship"]
	let gradeNames = ["K-2nd", "3rd-5th", "6th-8th", "9th-12th"]
	
	
	func loadLessons(completionHandler: ([String:AnyObject]?) -> ()) {
		FIRDatabase.database().reference().child("lessons").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				self.lessons = snapshot.value as? [String:AnyObject]
				completionHandler(self.lessons)
			}
		}
	}
	
	func lessonsArray(pillars:[Int], gradeLevels:[Int])->Array<Lesson>?{
		if(lessons == nil){
			return nil
		}
		else{
			var lessonArray:Array<Lesson> = []
			let keyArray:[String] = Array(lessons!.keys)
			for key in keyArray {
				let object:[String:AnyObject] = lessons![key] as! [String:AnyObject]
				let lesson:Lesson = Lesson.init(key: key, dictionary: object)
				lessonArray.append(lesson)
			}
			
			var filteredArray:[Lesson] = []
			for lesson in lessonArray{
				if(pillars.contains(lesson.pillar!) && gradeLevels.contains(lesson.grade!)){
					filteredArray.append(lesson)
				}
			}

			return filteredArray
		}
	}
}
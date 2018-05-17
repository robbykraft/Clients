
import Firebase
import FirebaseDatabase

extension Notification.Name {
	static let pollenDidUpdate = Notification.Name("POLLEN_SAMPLES_DID_UPDATE")
}

class Data {
	static let shared = Data()
	
	// date(toString) : sample
	var pollenSamples:[String:PollenSample] = [:]
	
//	let bootTime:Date = Date()
	
	private init(){
		// if a new pollen count is taken while the app is open, reload data in app
		Database.database().reference(withPath: "/collections").observe(.value, with: { snapshot in
			NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
		})

//		let connectedRef = Database.database().reference(withPath: ".info/connected")
//		connectedRef.observe(.value, with: { snapshot in
//			if let connected = snapshot.value as? Bool , connected {
//				if(abs(self.bootTime.timeIntervalSinceNow) > 2.0){
//					// show banner: internet connected
//				}
//			} else {
//				if(abs(self.bootTime.timeIntervalSinceNow) > 2.0){
//					// show banner: internet down
//				}
//			}
//		})
	}
	
	func boot(){
		loopAndLoadData(numberOfDays: 15)
	}
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func getData(_ childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
		var reference = Database.database().reference()
		if(childURL != nil){
			reference = Database.database().reference().child(childURL!)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				completionHandler(snapshot.value as AnyObject?)
			}
		}
	}

	func loopAndLoadData(numberOfDays:Int){
		
		var tries = 0
		var successes = 0
		
		func queryOnce(){
			// build date for #days past
			var deltaDate = DateComponents()
			deltaDate.day = -tries
			let queryDate:Date = (Calendar.current as NSCalendar).date(byAdding: deltaDate, to: Date(), options: NSCalendar.Options.matchFirst)!
			let dateString = collectionsKey(forDate:queryDate)

			tries += 1
			Database.database().reference().child("collections/" + dateString).observeSingleEvent(of: .value) { (data) in
				if let d = data.value as? [String:Any]{
					let sample = PollenSample()
					sample.setFromDatabase(d)
					if let sampleDate = sample.date{
						let dateString = sampleDate.toString()
						self.pollenSamples[dateString] = sample
						NotificationCenter.default.post(name: .pollenDidUpdate, object: nil)
						successes += 1
					}
				} else{
					print("no entry for " + dateString + ". trying again")
				}
				// repeat if we need more days of data
				if(successes < numberOfDays && tries < 100){
					queryOnce()
				}
			}
		}
		queryOnce()
	}
	
	// daysPast is expecting a positive number. ("5" means 5 days ago)
	func collectionsKey(forDate date:Date) -> String{
		let yearNumber:Int = Calendar.current.component(.year, from: date)
		let monthNumber:Int = Calendar.current.component(.month, from: date)
		let dayNumber:Int = Calendar.current.component(.day, from: date)
		return "\(yearNumber)" + String(format: "%02d", monthNumber) + String(format: "%02d", dayNumber)
	}

}

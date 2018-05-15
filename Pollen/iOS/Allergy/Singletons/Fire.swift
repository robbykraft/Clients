//
//  FireUser.swift
//  Login
//
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.
//

/////////////////////////////////////////////////////////////////////////
// THREE PARTS: STORAGE, USER, DATABASE

// STORAGE:
// since Firebase Storage doesn't keep track of the files you upload,
// this maintains a record of the uploaded files in your database

// USER:
// Firebase comes with FireAuth with a "user" class, but you can't edit it.
// this singleton is for making and managing a separate "users" class
//  - each user is stored under their user.uid
//  - can add as many fields as you want (nickname, photo, etc..)


import Firebase
//import BRYXBanner

let IMAGE_DIRECTORY:String = "images/"
let DOCUMENT_DIRECTORY:String = "documents/"

class Fire {
	static let shared = Fire()
	
	let database: DatabaseReference = Database.database().reference()
	let storage = Storage.storage().reference()
	
	// this is up to you to manage - but cache database calls here if you want.
	var databaseCache: AnyObject?
	
	// can monitor, pause, resume the current upload task
	var currentUpload:StorageUploadTask?
	
	var myUID:String?
	
	let startTime:Date = Date()
	
	private init() {
		// setup USER listener
		Auth.auth().addStateDidChangeListener { auth, userData in
			if let user = userData{
				print("   AUTH LISTENER: user \(user.email ?? "") signed in")
				self.myUID = user.uid
				self.checkIfUserExists(user, completionHandler: { (exists) in
					if(exists){ }
					else{
						self.createNewUserEntry(user, completionHandler: { (success) in
						})
					}
				})
			} else {
				self.myUID = nil
				print("   AUTH LISTENER: no user")
			}
		}
		
		let connectedRef = Database.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if let connected = snapshot.value as? Bool , connected {
//				print("INTERNET CONNECTION ESTABLISHED")
				if(abs(self.startTime.timeIntervalSinceNow) > 2.0){
//					let banner = Banner(title: "Internet", subtitle: "Connection Established", image: UIImage(named: "Icon"), backgroundColor: Style.shared.green)
//					banner.dismissesOnTap = true
//					banner.show(duration: 2.0)
				}
			} else {
//				print("INTERNET CONNECTION DOWN")
				if(abs(self.startTime.timeIntervalSinceNow) > 2.0){
//					let banner = Banner(title: "Internet", subtitle: "Not Connected", image: UIImage(named: "Icon"), backgroundColor: Style.shared.red)
//					banner.dismissesOnTap = true
//					banner.show(duration: 2.0)
				}
			}
		})
		
//		setup ref for the daily reading, if it changes tell the app to update itself:
		let collectionsRef = Database.database().reference(withPath: "/collections")
		collectionsRef.observe(.value, with: { snapshot in
			let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
			appDelegate.rootViewController.downloadAndRefresh()
		})

	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  DATABASE
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func getData(_ childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
		var reference = database
		if(childURL != nil){
			reference = database.child(childURL!)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				completionHandler(snapshot.value as AnyObject?)
			}
		}
	}
	
	func newUniqueObjectAtPath(_ childURL:String, object:AnyObject, completionHandler: ((Error?, DatabaseReference) -> ())?) {
		database.child(childURL).childByAutoId().setValue(object) { (error, ref) in
			if(completionHandler != nil){
				completionHandler!(error, ref)
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  USER
	
	func getUser(_ completionHandler: @escaping (String?, [String:AnyObject]?) -> ()) {
		let user = Auth.auth().currentUser
		database.child("users").child(user!.uid).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil, nil)
			} else {
				let userData:[String:AnyObject]? = snapshot.value as! [String:AnyObject]?
				completionHandler(user!.uid, userData)
			}
		}
	}
	
	func checkIfUserExists(_ user: User, completionHandler: @escaping (Bool) -> ()) {
		database.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(false)
			} else {
				let userDict:[String:AnyObject] = snapshot.value as! [String:AnyObject]
				if(userDict["createdAt"] != nil){
					completionHandler(true)
				} else{
					completionHandler(false)
				}
			}
		}
	}
	
	func updateUserWithKeyAndValue(_ key:String, value:AnyObject, completionHandler: ((_ success:Bool) -> ())? ) {
		print("saving \(value) into \(key)")
		let user = Auth.auth().currentUser
		database.child("users").child(user!.uid).updateChildValues([key:value]) { (error, ref) in
			if (error == nil){
				if(completionHandler != nil){
					completionHandler!(true)
				}
			} else{
				if(completionHandler != nil){
					completionHandler!(false)
				}
			}
		}
	}
	
	func createNewUserEntry(_ user:User, completionHandler: ((_ success:Bool) -> ())? ) {
		// copy user data over from AUTH
		let emailString:String = user.email!
		let newUser:[String:AnyObject] = [
//			"name"     : user.displayName! ,
//			"image"    : user.photoURL!,
			"email": emailString as AnyObject,
			"createdAt": Date.init().timeIntervalSince1970 as AnyObject
		]
		database.child("users").child(user.uid).updateChildValues(newUser) { (error, ref) in
			if error == nil{
				if(completionHandler != nil){
					print("added \(emailString) to the database")
					completionHandler!(true)
				}
			} else{
				// error creating user
				completionHandler!(false)
			}
		}
	}
	
	func user() -> User {
		return (Auth.auth().currentUser)!
	}
	
}

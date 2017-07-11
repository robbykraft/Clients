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
import BRYXBanner

let IMAGE_DIRECTORY:String = "images/"
let DOCUMENT_DIRECTORY:String = "documents/"

enum StorageFileType {
	case image_JPG, image_PNG, document_PDF
}

class Fire {
	static let shared = Fire()
	
	let database: FIRDatabaseReference = FIRDatabase.database().reference()
	let storage = FIRStorage.storage().reference()
	
	// this is up to you to manage - but cache database calls here if you want.
	var databaseCache: AnyObject?
	
	// can monitor, pause, resume the current upload task
	var currentUpload:FIRStorageUploadTask?
	
	var myUID:String?
	
	let startTime:Date = Date()
	
	fileprivate init() {
		// setup USER listener
		FIRAuth.auth()?.addStateDidChangeListener { auth, user in
			if user != nil {
				print("   AUTH LISTENER: user \(user?.email!) signed in")
				self.myUID = user?.uid
				self.checkIfUserExists(user!, completionHandler: { (exists) in
					if(exists){ }
					else{
						self.createNewUserEntry(user!, completionHandler: { (success) in
						})
					}
				})
			} else {
				self.myUID = nil
				print("   AUTH LISTENER: no user")
			}
		}
		
		let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if let connected = snapshot.value as? Bool , connected {
//				print("INTERNET CONNECTION ESTABLISHED")
				if(abs(self.startTime.timeIntervalSinceNow) > 2.0){
					let banner = Banner(title: "Internet", subtitle: "Connection Established", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
					banner.dismissesOnTap = true
					banner.show(duration: 2.0)
				}
			} else {
//				print("INTERNET CONNECTION DOWN")
				if(abs(self.startTime.timeIntervalSinceNow) > 2.0){
					let banner = Banner(title: "Internet", subtitle: "Not Connected", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:174.0/255.0, green:48.0/255.0, blue:51.5/255.0, alpha:1.000))
					banner.dismissesOnTap = true
					banner.show(duration: 2.0)
				}
			}
		})
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  DATABASE
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func loadData(_ childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
		var reference = database
		if(childURL != nil){
			reference = database.child(childURL!)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				completionHandler(snapshot.value as AnyObject?)
			}
		}
	}
	
	func newUniqueObjectAtPath(_ childURL:String, object:AnyObject, completionHandler: ((Error?, FIRDatabaseReference) -> ())?) {
		database.child(childURL).childByAutoId().setValue(object) { (error, ref) in
			if(completionHandler != nil){
//				print(ref)
				completionHandler!(error, ref)
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  USER
	
	func getUser(_ completionHandler: @escaping (String?, [String:AnyObject]?) -> ()) {
		let user = FIRAuth.auth()?.currentUser
		database.child("users").child(user!.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil, nil)
			} else {
				let userData:[String:AnyObject]? = snapshot.value as! [String:AnyObject]?
				completionHandler(user!.uid, userData)
			}
		}
	}
	
	func checkIfUserExists(_ user: FIRUser, completionHandler: @escaping (Bool) -> ()) {
		database.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
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
		let user = FIRAuth.auth()?.currentUser
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
	
	func createNewUserEntry(_ user:FIRUser, completionHandler: ((_ success:Bool) -> ())? ) {
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
	
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  STORAGE
	
	// specify a UUIDFilename, or it will generate one for you
	func uploadFileAndMakeRecord(_ data:Data, folder:String?, fileType:StorageFileType, description:String?, completionHandler: @escaping (_ downloadURL:URL?) -> ()) {
		
		// prep file info
		var filename:String = UUID.init().uuidString
		var storagePath:String
		var databaseDirectory:String
		var dir:String = ""
		switch fileType {
		case .image_JPG:
			filename = filename + ".jpg"
			dir = IMAGE_DIRECTORY
			break
		case .image_PNG:
			filename = filename + ".png"
			dir = IMAGE_DIRECTORY
			break
		case .document_PDF:
			filename = filename + ".pdf"
			dir = DOCUMENT_DIRECTORY
			break
		}
		// WAIT: if they specify a directory folder, use that instead
		// if user-specified directory, make sure it ends with /
		if let f:String = folder{
			// make sure string isn't empty, OR, string is "/" -- cannot save at root, will save at "files/" instead
			if(!f.isEmpty && !(f.characters.count == 1 && f.characters.first == "/") ){
				dir = f
				if(dir.characters.last != "/"){
					dir.append("/")
				}
			}
		}
		
		storagePath = dir + filename
		databaseDirectory = "files/" + dir
		
		// STEP 1 - upload file to storage
		currentUpload = storage.child(storagePath).put(data, metadata: nil) { metadata, error in
			// TODO: make currentUpload an array, if upload in progress add this to array
			if (error != nil) {
				print(error?.localizedDescription ?? "")
				completionHandler(nil)
			} else {
				// STEP 2 - record new file in database
				let downloadURL = metadata!.downloadURL()!
				let key = self.database.child(databaseDirectory).childByAutoId().key
				var descriptionString:String = ""
				if(description != nil){
					descriptionString = description!
				}
				let entry:Dictionary = ["file":storagePath,
				                        "type":stringForStorageFileType(fileType),
				                        "size":data.count,
				                        "description":descriptionString,
				                        "url":downloadURL.absoluteString] as [String : Any]
				self.database.child(databaseDirectory).updateChildValues([key:entry]) { (error, ref) in
					completionHandler(downloadURL)
				}
			}
		}
	}
}

func stringForStorageFileType(_ fileType:StorageFileType) -> String {
	switch fileType {
	case .image_JPG:    return "JPG"
	case .image_PNG:    return "PNG"
	case .document_PDF: return "PDF"
	}
}


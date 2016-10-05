//
//  LocalCache.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class Cache {
	static let shared = Cache()
	fileprivate init() { }
	
	// Key is userUID
	var profileImage : Dictionary<String, UIImage> = Dictionary()
	
	// Key is filename in the images/ folder in the bucket
	var storageBucket : Dictionary<String, UIImage> = Dictionary()

	func imageFromStorageBucket(_ filename: String, completionHandler: @escaping (_ image:UIImage?, _ didRequireDownload:Bool) -> ()) {
		if(storageBucket[filename] != nil){
			//TODO: if image on database has changed, we need a force-refresh command
			completionHandler(Cache.shared.storageBucket[filename]!, false)
			return
		}
		
		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)
		
		imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
			if(data != nil){
				if let imageData = data as Data? {
					Cache.shared.storageBucket[filename] = UIImage(data: imageData)
					completionHandler(Cache.shared.storageBucket[filename]!, true)
				}
			}
		}
		
	}
}



extension UIImageView {
	
	public func profileImageFromUID(_ uid: String){
		if(Cache.shared.profileImage[uid] != nil){
			self.image = Cache.shared.profileImage[uid]!
			return
		}
		Fire.shared.getUser { (userUID, userData) in
			if(userData != nil){
				if let urlString = userData!["image"]{
					if let url = URL(string: urlString as! String){
						let request:URLRequest = URLRequest(url: url)
						let session = URLSession.shared
						let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
							DispatchQueue.main.async {
								if let imageData = data as Data? {
									Cache.shared.profileImage[uid] = UIImage(data: imageData)
									self.image = UIImage(data: imageData)
								}
							}
						})
						task.resume()
					}
				}
				else{
//					print("user exists, but has no image")
					return
				}
			}
		}
	}

	public func imageFromUrl(_ urlString: String) {
		if let url = URL(string: urlString) {
			let request:URLRequest = URLRequest(url: url)
			let session = URLSession.shared
			let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
				DispatchQueue.main.async {
					if let imageData = data as Data? {
						self.image = UIImage(data: imageData)
					}
				}
			})
			task.resume()
		}
	}
	
	
	
	public func imageFromStorageBucket(_ filename: String){
		if(Cache.shared.storageBucket[filename] != nil){
			self.image = Cache.shared.storageBucket[filename]!
			return
		}

		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)

		imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
			if(data != nil){
//				dispatch_async(dispatch_get_main_queue()) {
					if let imageData = data as Data? {
						Cache.shared.storageBucket[filename] = UIImage(data: imageData)
						self.image = UIImage(data: imageData)
					}
//				}
			}
		}
	}

}

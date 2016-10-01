//
//  ViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	let emailField:UITextField = UITextField()
	let passwordField:UITextField = UITextField()
	let loginButton:UIButton = UIButton()
	
	let iconImageView = UIImageView()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = Style.shared.whiteSmoke
		emailField.backgroundColor = UIColor.whiteColor()
		passwordField.backgroundColor = UIColor.whiteColor()
		passwordField.secureTextEntry = true
		
		emailField.delegate = self
		passwordField.delegate = self
		
		emailField.placeholder = "Email Address"
		passwordField.placeholder = "Password"
		
		let paddingEmail = UIView.init(frame: CGRectMake(0, 0, 5, 20))
		let paddingPassword = UIView.init(frame: CGRectMake(0, 0, 5, 20))
		emailField.leftView = paddingEmail
		passwordField.leftView = paddingPassword
		emailField.leftViewMode = .Always
		passwordField.leftViewMode = .Always

		self.view.addSubview(emailField)
		self.view.addSubview(passwordField)

		loginButton.setTitle("Login / Create Account", forState: UIControlState.Normal)
		loginButton.addTarget(self, action: #selector(buttonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		loginButton.backgroundColor = Style.shared.lightBlue
		
		self.view.addSubview(loginButton)
		
		iconImageView.image = UIImage(named: "icon")
		iconImageView.alpha = 0.05
		self.view.addSubview(iconImageView)
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		emailField.frame = CGRectMake(0, self.view.bounds.size.height * 0.5 - 52 - 20, self.view.bounds.size.width, 52)
		passwordField.frame = CGRectMake(0, self.view.bounds.size.height * 0.5, self.view.bounds.size.width, 52)
		loginButton.frame = CGRectMake(0, self.view.bounds.size.height * 0.5 + 52 + 20, self.view.bounds.size.width, 44)
		iconImageView.frame = CGRectMake(0, 0, self.view.bounds.size.height * 0.4, self.view.bounds.size.height * 0.4)
		iconImageView.center = CGPointMake(self.view.center.x, (self.view.bounds.size.height * 0.5 - 52 - 20) * 0.5)
	}
	
	func copyUserFromAuth(){
		if let user = FIRAuth.auth()?.currentUser {
			let name:NSString = user.displayName!
			let email:NSString = user.email!
			let photoUrl:NSURL = user.photoURL!
			let uid = user.uid;
			
			let ref = FIRDatabase.database().reference()
			let key = uid
			
			let userDict:NSDictionary = [ "name"    : name ,
			                              "email"   : email,
			                              "photoUrl"    : photoUrl]
			
			let childUpdates = ["/users/\(key)": userDict]
			ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
				// now users exist in the database
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func buttonHandler(){
		loginWithCredentials(emailField.text!, pass: passwordField.text!)
	}
	
	func loginWithCredentials(username: String, pass:String){
		FIRAuth.auth()?.signInWithEmail(username, password: pass, completion: { (user, error) in
			if(error == nil){
				// Success, logging in with email
				self.presentViewController(MasterController(), animated: true, completion: nil);
			} else{
				// 2 POSSIBILITIES: (1) Account doesn't exist  (2) Account exists, password was incorrect
				FIRAuth.auth()?.createUserWithEmail(username, password: pass, completion: { (user, error) in
					if(error == nil){
						// Success, created account, logging in now
						self.presentViewController(SetupProfileViewController(), animated: true, completion: nil)
					} else{
						let errorMessage = "Account with \(username) exists, but password is incorrect"
						let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .Alert)
						let action1 = UIAlertAction.init(title: "Try Again", style: .Default, handler: nil)
						alert.addAction(action1)
						self.presentViewController(alert, animated: true, completion: nil)
					}
				})
			}
		})
	}
}


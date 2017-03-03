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
		emailField.backgroundColor = UIColor.white
		passwordField.backgroundColor = UIColor.white
		passwordField.isSecureTextEntry = true
		
		emailField.delegate = self
		passwordField.delegate = self
		
		emailField.placeholder = "Email Address"
		passwordField.placeholder = "Password"
		
		let paddingEmail = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
		let paddingPassword = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
		emailField.leftView = paddingEmail
		passwordField.leftView = paddingPassword
		emailField.leftViewMode = .always
		passwordField.leftViewMode = .always

		self.view.addSubview(emailField)
		self.view.addSubview(passwordField)

		loginButton.setTitle("Login / Create Account", for: UIControlState())
		loginButton.addTarget(self, action: #selector(buttonHandler), for: UIControlEvents.touchUpInside)
		loginButton.backgroundColor = Style.shared.lightBlue
		
		self.view.addSubview(loginButton)
		
		iconImageView.image = UIImage(named: "icon")
		iconImageView.alpha = 0.05
		self.view.addSubview(iconImageView)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		emailField.frame = CGRect(x: 0, y: self.view.bounds.size.height * 0.5 - 52 - 20, width: self.view.bounds.size.width, height: 52)
		passwordField.frame = CGRect(x: 0, y: self.view.bounds.size.height * 0.5, width: self.view.bounds.size.width, height: 52)
		loginButton.frame = CGRect(x: 0, y: self.view.bounds.size.height * 0.5 + 52 + 20, width: self.view.bounds.size.width, height: 44)
		iconImageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.height * 0.4, height: self.view.bounds.size.height * 0.4)
		iconImageView.center = CGPoint(x: self.view.center.x, y: (self.view.bounds.size.height * 0.5 - 52 - 20) * 0.5)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func buttonHandler(){
		loginWithCredentials(emailField.text!, pass: passwordField.text!)
	}

	func loginWithCredentials(_ username: String, pass:String){
		FIRAuth.auth()?.signIn(withEmail: username, password: pass, completion: { (user, error) in
			if(error == nil){
				// Success, logging in with email
				self.present(MasterController(), animated: true, completion: nil);
			} else{
				print("ERROR:")
//				print(error?.localizedDescription)
				print("MORE:")
				print(error.debugDescription)
				// 2 POSSIBILITIES: (1) Account doesn't exist  (2) Account exists, password was incorrect
				FIRAuth.auth()?.createUser(withEmail: username, password: pass, completion: { (user, error) in
					if(error == nil){
						// Success, created account, logging in now
						self.present(SetupProfileViewController(), animated: true, completion: nil)
					} else{
						let errorMessage = "Account exists but password is incorrect"
						let alert = UIAlertController(title: username, message: errorMessage, preferredStyle: .alert)
						let action1 = UIAlertAction.init(title: "Try Again", style: .default, handler: nil)
						let action2 = UIAlertAction.init(title: "Send a password-reset email", style: .destructive, handler: { (action) in
							FIRAuth.auth()?.sendPasswordReset(withEmail: username) { error in
								if error == nil{
									// Password reset email sent.
									let alert = UIAlertController(title: "Email Sent", message: nil, preferredStyle: .alert)
									let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
									alert.addAction(action1)
									self.present(alert, animated: true, completion: nil)
								} else{
									let alert = UIAlertController(title: "Error sending email", message: error!.localizedDescription, preferredStyle: .alert)
									let action1 = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
									alert.addAction(action1)
									self.present(alert, animated: true, completion: nil)
								}
							}
						})
						alert.addAction(action1)
						alert.addAction(action2)
						self.present(alert, animated: true, completion: nil)
					}
				})
			}
		})
	}

}


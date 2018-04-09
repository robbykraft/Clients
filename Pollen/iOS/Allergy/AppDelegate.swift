//
//  AppDelegate.swift
//  Allergy
//
//  Created by Robby on 4/3/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let gcmMessageIDKey = "gcm.message_id"
	
	let rootViewController = ViewController()
	
	func quickLaunch(){
		self.window = UIWindow()
		self.window?.frame = UIScreen.main.bounds
		self.window?.rootViewController = rootViewController
		self.window?.makeKeyAndVisible()
	}
	
	func launchApp(_ requireLogin:Bool){
		self.window = UIWindow()
		self.window?.frame = UIScreen.main.bounds
		let loginVC : LoginViewController = LoginViewController()
		if(FIRAuth.auth()?.currentUser != nil){
			loginVC.emailField.text = FIRAuth.auth()?.currentUser?.email
		}
		self.window?.rootViewController = loginVC
		self.window?.makeKeyAndVisible()
		
		if(!requireLogin){
			loginVC.present(MasterNavigationController(), animated: false, completion: nil)
		}
	}
	
	func refreshAppIfNeeded(){
		let vc = UIApplication.topViewController()
		if let viewController = vc as? Preferences {
			viewController.tableView.reloadData()
		}
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Register for remote notifications. This shows a permission dialog on first run, to
		// show the dialog at a more appropriate time move this registration accordingly.
		// [START register_for_notifications]
		if #available(iOS 10.0, *) {
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
			
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			// For iOS 10 data message (sent via FCM)
			FIRMessaging.messaging().remoteMessageDelegate = self
			
		} else {
			let settings: UIUserNotificationSettings =
				UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
		
		// [END register_for_notifications]
		
		FIRApp.configure()
		
		// Check if launched from notification
		// 1
		if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
			// 2
			let aps = notification["aps"] as! [String: AnyObject]
			print("launched app by tapping push notification")
			print(aps)
			// 3
//			(window?.rootViewController as? UITabBarController)?.selectedIndex = 1
		}
		
		
		// [START add_token_refresh_observer]
		// Add observer for InstanceID token refresh callback.
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(self.tokenRefreshNotification),
		                                       name: .firInstanceIDTokenRefresh,
		                                       object: nil)
		// [END add_token_refresh_observer]
		
		_ = Fire.shared
		_ = Pollen.shared
		_ = Style.shared
		_ = Allergies.shared
		
		
		Pollen.shared.boot { (success) in
			self.quickLaunch()
		}
		
//		if (FIRAuth.auth()?.currentUser) != nil {
//			// User is signed in.
//			launchApp(false)
//		} else {
//			// No user is signed in.
//			launchApp(true)
//		}

		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

//	func applicationDidEnterBackground(_ application: UIApplication) {
//		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		self.refreshAppIfNeeded()
	}

//	func applicationDidBecomeActive(_ application: UIApplication) {
//		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
	                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		
		
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		let aps = userInfo["aps"] as! [String: AnyObject]
		print("aps")
		print(aps)
		if (aps["content-available"] as? NSString)?.integerValue == 1 {
			
			print("Silet push!")
			completionHandler(UIBackgroundFetchResult.newData)
		} else  {
			print("not a silent push")
			print("here we go!")
			print("get the app to reload today's new allergy contents!")
			completionHandler(UIBackgroundFetchResult.newData)
		}
	}
	// [END receive_message]
	
	// [START refresh_token]
	func tokenRefreshNotification(_ notification: Notification) {
		if let refreshedToken = FIRInstanceID.instanceID().token() {
			print("InstanceID token: \(refreshedToken)")
		}
		
		// Connect to FCM since connection may have failed when attempted before having a token.
		connectToFcm()
	}
	// [END refresh_token]
	
	// [START connect_to_fcm]
	func connectToFcm() {
		// Won't connect since there is no token
		guard FIRInstanceID.instanceID().token() != nil else {
			return
		}
		
		// Disconnect previous FCM connection if it exists.
		FIRMessaging.messaging().disconnect()
		
		FIRMessaging.messaging().connect { (error) in
			if error != nil {
				print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
			} else {
				print("Connected to FCM.")
			}
		}
	}
	// [END connect_to_fcm]
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Unable to register for remote notifications: \(error.localizedDescription)")
	}
	
	
	// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
	// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
	// the InstanceID token.
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		print("APNs token retrieved: \(deviceToken)")
		
		//		pusher.nativePusher().register(deviceToken: deviceToken)
		//		pusher.nativePusher().subscribe(interestName: "donuts")
		
		// With swizzling disabled you must set the APNs token here.
		// FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
	}
	
	// [START connect_on_active]
	func applicationDidBecomeActive(_ application: UIApplication) {
		connectToFcm()
	}
	// [END connect_on_active]
	
	// [START disconnect_from_fcm]
	func applicationDidEnterBackground(_ application: UIApplication) {
		FIRMessaging.messaging().disconnect()
		print("Disconnected from FCM.")
	}
	// [END disconnect_from_fcm]
	
	
	
	
}




// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
	                            willPresent notification: UNNotification,
	                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		// Change this to your preferred presentation option
		completionHandler([])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
	                            didReceive response: UNNotificationResponse,
	                            withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler()
	}
}
// [END ios_10_message_handling]




// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
	// Receive data message on iOS 10 devices while app is in the foreground.
	func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
		print(remoteMessage.appData)
	}
}
// [END ios_10_data_message_handling]



extension UIApplication {
	class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(base: nav.visibleViewController)
		}
		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				return topViewController(base: selected)
			}
		}
		if let presented = base?.presentedViewController {
			return topViewController(base: presented)
		}
		return base
	}
}


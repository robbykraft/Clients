//
//  AppDelegate.swift
//  Pollen
//
//  Created by Robby on 4/17/17.
//  Copyright © 2017 Robby Kraft. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?
	let gcmMessageIDKey = "gcm.message_id"

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		
		
		// Register for remote notifications. This shows a permission dialog on first run, to
		// show the dialog at a more appropriate time move this registration accordingly.
		// [START register_for_notifications]
		if #available(iOS 10.0, *) {
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
			
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

		return true
	}
	
	//Called when a notification is delivered to a foreground app.
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("User Info = ",notification.request.content.userInfo)
		completionHandler([.alert, .badge, .sound])
	}
 
	//Called to let your app know which action was selected by the user for a given notification.
	@available(iOS 10.0, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print("User Info = ",response.notification.request.content.userInfo)
		completionHandler()
	}
	
	// [START receive_message]
//	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//		// If you are receiving a notification message while your app is in the background,
//		// this callback will not be fired till the user taps on the notification launching the application.
//		// TODO: Handle data of notification
//
//		// Print message ID.
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("Message ID: \(messageID)")
//		}
//		// Print full message.
//		print(userInfo)
//		
//		let aps = userInfo["aps"] as! [String: AnyObject]
//		if (aps["content-available"] as? NSString)?.integerValue == 1 {
//			print("Silet push!")
//		} else  {
//			print("not a silent push")
//		}
//	}
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


	
	


	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
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






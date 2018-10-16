//
//  PollenNotificationDelegate.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/14/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

let USER_DEFAULTS_NOTIFICATION_HOUR:String = "notificationAlertHour"
let USER_DEFAULTS_NOTIFICATION_MINUTE:String = "notificationAlertMinute"

extension Notification.Name {
	static let pollenDidUpdate = Notification.Name("POLLEN_SAMPLES_DID_UPDATE")
	static let symptomDidUpdate = Notification.Name("SYMPTOM_ENTRY_DID_UPDATE")

	static let chartDataDidUpdate = Notification.Name("CHART_DATA_DID_UPDATE")

	static let queryRequestSymptom = NSNotification.Name("QUERY_REQUEST_SYMPTOM")
	static let queryRequestExposure = NSNotification.Name("QUERY_REQUEST_EXPOSURE")
	static let queryRequestSymptomAndExposure = NSNotification.Name("QUERY_REQUEST_SYMPTOM_AND_EXPOSURE")
}

class PollenNotifications: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {

	static let shared = PollenNotifications()
	
	fileprivate override init(){
		super.init()
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		
		// register local
		registerLocalCategory()
		
		// register remote
		registerRemoteNotifications()
	}
	
	func setNotificationTime(hour:Int, minute:Int){
		UserDefaults.standard.set(hour, forKey: USER_DEFAULTS_NOTIFICATION_HOUR)
		UserDefaults.standard.set(minute, forKey: USER_DEFAULTS_NOTIFICATION_MINUTE)
		UserDefaults.standard.synchronize()
		print("updated time \(hour):\(minute)")
		isLocalTimerRunning(completionHandler: { (isRunning) in
			if isRunning{
				self.enableLocalTimer(completionHandler: nil)
			}
		})
	}
	
	func getNotificationTime() -> (Int, Int){
		if let hour = UserDefaults.standard.object(forKey:USER_DEFAULTS_NOTIFICATION_HOUR) as? Int{
			if let minute = UserDefaults.standard.object(forKey:USER_DEFAULTS_NOTIFICATION_MINUTE) as? Int{
				print("getNotificationTime \(hour):\(minute)")
				return (hour, minute)
			}
		}
		return (18, 0)
	}
	
	let center = UNUserNotificationCenter.current()
	
	func check(){
//		self.center.removeAllPendingNotificationRequests()
		self.center.getPendingNotificationRequests { (requestList) in
			print("found pending requests")
			print(requestList.count)
			for r in requestList{
				print(r.trigger?.repeats ?? "")
				print(r.content.body)
			}
		}
		self.center.getDeliveredNotifications { (deliveredList) in
			print("found delivered requests")
			print(deliveredList.count)
			for delivered in deliveredList{
				print(delivered.request.content.body)
			}
		}
	}
	
	func isLocalTimerRunning(completionHandler: ((Bool) -> ())?) {
		self.center.getPendingNotificationRequests { (requestList) in
			for r in requestList{
				if let rep = r.trigger?.repeats{
					// yes, our best guess, a timer that has a repeat is currently running in the background
					if rep == true{
						DispatchQueue.main.async {
							completionHandler?(true)
						}
						return
					}
				}
			}
			DispatchQueue.main.async {
				completionHandler?(false)
			}
		}
	}
	
	func registerLocalCategory(){
		// add buttons to category
		let symptomRatings:[SymptomRating] = [.severe, .medium, .light, .none]
		let notificationActions = symptomRatings.map { (rating) -> UNNotificationAction in
			return UNNotificationAction(identifier: "ATXPollen\(rating.asString().capitalized)Action", title: rating.asString(), options: [])
		}
//		let deleteAction = UNNotificationAction(identifier: "ATXPollenDeleteAction",
//												title: "Delete", options: [.destructive])
		let category = UNNotificationCategory(identifier: "ATXPollenReminderCategory",
											  actions: notificationActions,
											  intentIdentifiers: [], options: [])
		center.setNotificationCategories([category])
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Play sound and show alert to the user
		completionHandler([.alert,.sound])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
		case "ATXPollenSevereAction":
			print("severe")
			let entry = SymptomEntry(date: Date(), location: nil, rating: .severe, exposures: nil)
			Symptom.shared.updateDatabaseWith(entry: entry)
		case "ATXPollenMediumAction":
			print("medium")
			let entry = SymptomEntry(date: Date(), location: nil, rating: .medium, exposures: nil)
			Symptom.shared.updateDatabaseWith(entry: entry)
		case "ATXPollenLightAction":
			print("light")
			let entry = SymptomEntry(date: Date(), location: nil, rating: .light, exposures: nil)
			Symptom.shared.updateDatabaseWith(entry: entry)
		case "ATXPollenNoneAction":
			print("none")
			let entry = SymptomEntry(date: Date(), location: nil, rating: .none, exposures: nil)
			Symptom.shared.updateDatabaseWith(entry: entry)
		case UNNotificationDismissActionIdentifier: print("Dismiss Action")
		case UNNotificationDefaultActionIdentifier:
			// app opened from pressing notification without answering question - show popup window
			print("Default")
			NotificationCenter.default.post(name: .queryRequestSymptomAndExposure, object: nil, userInfo: ["date":Date()])
		default: print("Unknown action")
		}
		completionHandler()
	}

	func requestNotificationAccess(completionHandler: ((Bool) -> ())?) {
		let options: UNAuthorizationOptions = [.alert, .sound];
		center.requestAuthorization(options: options) {
			(granted, error) in
			completionHandler?(granted)
			if !granted {
				print("Something went wrong")
			}
		}
	}
	
	func disableLocalTimer(){
		self.center.removeAllPendingNotificationRequests()
	}
	
	func enableLocalTimer(completionHandler: ((Bool) -> ())?) {
		// create the trigger
		let (hour, minute) = getNotificationTime()
		let alertTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
		let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second], from: alertTime)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
		// create the notification
		let content = UNMutableNotificationContent()
		content.title = "How are your allergies today?"
		content.body = "slide to respond"
		content.sound = UNNotificationSound.default()
		content.categoryIdentifier = "ATXPollenReminderCategory"
		// run notification
		let identifier = "ATXPollenLocalNotification"
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		center.add(request, withCompletionHandler: { (error) in
			if let error = error {
				print(error)
				DispatchQueue.main.async {
					completionHandler?(false)
				}
			} else{
				DispatchQueue.main.async {
					completionHandler?(true)
				}
			}
		})
	}
	
	func isLocalEnabled(completionHandler: ((Bool) -> ())?) {
		center.getNotificationSettings { (settings) in
			DispatchQueue.main.async {
				completionHandler?(settings.authorizationStatus == .authorized)
			}
		}
	}
	
	func openSettings(){
		if let url = URL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.shared.open(url, options: ["root":"NOTIFICATIONS_ID"], completionHandler: nil)
		} else{ }
	}
	
	func enableLocalNotifications(completionHandler: ((Bool) -> ())?) {
		isLocalEnabled { (authorized) in
			if authorized{
				DispatchQueue.main.async {
					completionHandler?(true)
				}
			} else{
				self.requestNotificationAccess(completionHandler: { (requestAccepted) in
					if requestAccepted{
						DispatchQueue.main.async {
							completionHandler?(true)
						}
					} else{
						DispatchQueue.main.async {
							self.openSettings()
						}
					}
				})
			}
		}
	}
	
	func testNotification(){
		
		let content = UNMutableNotificationContent()
		content.title = "How are your allergies today?"
		content.body = "slide to respond"
		content.sound = UNNotificationSound.default()
		content.categoryIdentifier = "ATXPollenReminderCategory"
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20,
														repeats: false)
		let identifier = "ATXPollenLocalNotification"
		let request = UNNotificationRequest(identifier: identifier,
											content: content, trigger: trigger)

		center.add(request, withCompletionHandler: { (error) in
			if let error = error {
				print(error)
				// Something went wrong
			}
		})
	}
	
	
	//MARK: REMOTE NOTIFICATIONS
	
	func registerRemoteNotifications(){
		let application = UIApplication.shared
		if #available(iOS 10.0, *) {
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
			// For iOS 10 data message (sent via FCM
			Messaging.messaging().delegate = self
		} else {
			let settings: UIUserNotificationSettings =
				UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		application.registerForRemoteNotifications()
	}

	func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
		print("applicationReceivedRemoteMessage")
		print(remoteMessage.appData)
	}
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		print("didReceiveRegistrationToken")
		print(fcmToken)
	}
	
}




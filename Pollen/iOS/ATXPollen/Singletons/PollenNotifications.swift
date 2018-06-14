//
//  PollenNotificationDelegate.swift
//  ATXPollen
//
//  Created by Robby Kraft on 6/14/18.
//  Copyright © 2018 Allergy & Asthma Associates. All rights reserved.
//

import UIKit
import UserNotifications

class PollenNotifications: NSObject, UNUserNotificationCenterDelegate {

	static let shared = PollenNotifications()
	
	fileprivate override init(){
		super.init()
		let center = UNUserNotificationCenter.current()
		center.delegate = self
		registerCategory()
	}
	
	let center = UNUserNotificationCenter.current()
	
	func registerCategory(){
		// add buttons to category
		let symptomRatings:[SymptomRating] = [.severe, .medium, .light, .none]
		let notificationActions = symptomRatings.map { (rating) -> UNNotificationAction in
			return UNNotificationAction(identifier: "UYL\(rating.asString().capitalized)Action", title: rating.asString(), options: [])
		}
//		let deleteAction = UNNotificationAction(identifier: "UYLDeleteAction",
//												title: "Delete", options: [.destructive])
		let category = UNNotificationCategory(identifier: "UYLReminderCategory",
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
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		
		// Determine the user action
		switch response.actionIdentifier {
		case UNNotificationDismissActionIdentifier:
			print("Dismiss Action")
		case UNNotificationDefaultActionIdentifier:
			print("Default")
		case "Snooze":
			print("Snooze")
		case "Delete":
			print("Delete")
		default:
			print("Unknown action")
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
	
	func checkNotificationAuthorizationStatus(completionHandler: ((Bool) -> ())?) {
		center.getNotificationSettings { (settings) in
			completionHandler?(settings.authorizationStatus == .authorized)
		}
	}
	
	func openSettings(){
		if let url = URL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.shared.open(url, options: ["root":"NOTIFICATIONS_ID"], completionHandler: nil)
		} else{ }
	}
	
	func testNotification(){
		
		let content = UNMutableNotificationContent()
		content.title = "How are your allergies today?"
		content.body = "slide to respond"
		content.sound = UNNotificationSound.default()
		content.categoryIdentifier = "UYLReminderCategory"
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20,
														repeats: false)
		
//		let date = Date(timeIntervalSinceNow: 3600)
//		let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
//													repeats: false)

/// daily trigger
//		let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
//		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
		
		
		let identifier = "UYLLocalNotification"
		let request = UNNotificationRequest(identifier: identifier,
											content: content, trigger: trigger)
		
		center.add(request, withCompletionHandler: { (error) in
			if let error = error {
				print(error)
				// Something went wrong
			}
		})
		
		
	}
	
}

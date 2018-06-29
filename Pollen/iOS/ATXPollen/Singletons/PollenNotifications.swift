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
					}
				}
			}
		}

	}
	
	func registerCategory(){
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
		case "ATXPollenMediumAction":
			print("medium")
		case "ATXPollenLowAction":
			print("low")
		case "ATXPollenNoneAction":
			print("none")
		case UNNotificationDismissActionIdentifier: print("Dismiss Action")
		case UNNotificationDefaultActionIdentifier: print("Default")
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
		let sixPM = Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: Date())!
		let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second], from: sixPM)
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
	
}

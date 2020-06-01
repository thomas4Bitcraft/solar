//
//  SunsetNotification.swift
//  Sunset
//
//  Created by Thomas Brandauer on 02.06.20.
//  Copyright © 2020 Hamon Parvizi. All rights reserved.
//

import CoreLocation
import Foundation
import UserNotifications
import Solar

struct SunsetNotification {
    func sendSunsetNotifcationwith(content: String, on time: Date){
        print("Scheduling Notification")
        print(TimeInterval(TimeZone.current.secondsFromGMT()))
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

            // Enable or disable features based on the authorization.
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Sunset"
            notificationContent.body = content
            notificationContent.sound = .default

            // Create the trigger as a repeating event.
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time.addingTimeInterval(-300))
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: notificationContent, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.add(request)
        }
    }
}

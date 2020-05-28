//
//  AppDelegate.swift
//  Sunset
//
//  Created by Hamon Parvizi on 5/2/20.
//  Copyright © 2020 Hamon Parvizi. All rights reserved.
//

import UIKit
import SwiftUI
import Solar
import CoreLocation
import BackgroundTasks
class SunsetString: ObservableObject {
    @Published var label: String = "Loading..."
}
let sunsetString = SunsetString()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    var window: UIWindow?
    var location = CLLocationCoordinate2D.init(latitude: 37.773972, longitude: -122.431297)
    let locationmanager = CLLocationManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.hamonpa.sunset.refresh", using: nil) { task in
            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        ScheduleSunsetNotification()
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        locationmanager.allowsBackgroundLocationUpdates = true
        locationmanager.requestAlwaysAuthorization()
        locationmanager.startUpdatingLocation()
        return true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l = locations.first else {return}
        print (l)
        self.location = l.coordinate
        ScheduleSunsetNotification()
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func scheduleAppRefresh() {
       print("scheduleAppRefresh")
        let request = BGAppRefreshTaskRequest(identifier: "com.hamonpa.sunset.refresh")
       // Fetch no earlier than 15 minutes from now
       request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
   
    func ScheduleSunsetNotification (){
        print("Scheduling Notification")
        print(TimeInterval(TimeZone.current.secondsFromGMT()))
        let location = self.location
        let solar = Solar(for: Date(timeIntervalSinceNow: TimeInterval(TimeZone.current.secondsFromGMT())), coordinate: location)
        let time = (solar?.sunset)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        dateFormatter.timeZone = TimeZone.current
        let text = dateFormatter.string(from: time)
        DispatchQueue.main.async {
            sunsetString.label = text
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            
            // Enable or disable features based on the authorization.
        let content = UNMutableNotificationContent()
        content.title = "Sunset"
        content.body = text
        content.sound = .default
            
//         Configure the recurring date.
         let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: time.addingTimeInterval(-300.0))
//            var dateComponents = DateComponents()
//            dateComponents.calendar = Calendar.current
//            dateComponents.hour = 17
//            dateComponents.minute = 22
    
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
            }
        }
    }
    
        
    func handleAppRefresh(task: BGAppRefreshTask) {
        print("handleAppRefresh")
      // Schedule a new refresh task
      scheduleAppRefresh()

      // Create an operation that performs the main part of the background task
        let operation = BlockOperation.init {
            self.ScheduleSunsetNotification()
            }
      
      // Provide an expiration handler for the background task
      // that cancels the operation
      task.expirationHandler = {
         operation.cancel()
      }

      // Inform the system that the background task is complete
      // when the operation completes
      operation.completionBlock = {
         task.setTaskCompleted(success: !operation.isCancelled)
      }

      // Start the operation
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(operation)
    }


}

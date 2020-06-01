//
//  AppDelegate.swift
//  Sunset
//
//  Created by Hamon Parvizi on 5/2/20.
//  Copyright © 2020 Hamon Parvizi. All rights reserved.
//

import UIKit
import SwiftUI
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let sunsetNotification = SunsetNotification()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // start location manager
        SolarManager.instance.start()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.hamonpa.sunset.refresh", using: nil) { task in
            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        return true
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
    
        
    func handleAppRefresh(task: BGAppRefreshTask) {
        print("handleAppRefresh")
        // Schedule a new refresh task
        scheduleAppRefresh()

        // Create an operation that performs the main part of the background task
        let operation = BlockOperation.init {
            self.sunsetNotification.sendSunsetNotifcationwith(
                content: SolarManager.instance.sunsetString.label,
                on: SolarManager.instance.sunsetTime
            )
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

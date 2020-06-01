//
//  LocationManager.swift
//  Sunset
//
//  Created by Thomas Brandauer on 02.06.20.
//  Copyright © 2020 Hamon Parvizi. All rights reserved.
//

import Foundation
import CoreLocation
import Solar

class SolarManager: NSObject, CLLocationManagerDelegate {

    // use a singleton to fetch location
    static let instance = SolarManager()

    let locationmanager = CLLocationManager()
    let sunsetNotification = SunsetNotification()
    var currentLocation = CLLocationCoordinate2D.init(latitude: 37.773972, longitude: -122.431297)

    let sunsetString = SunsetString()
    var sunsetTime = Date()

    override init () {
        super.init()
        locationmanager.delegate = self
        locationmanager.requestAlwaysAuthorization()

        // try to backup sunset notification on app start with harcoded location
        getSolarStringAndSendNotification()
    }

    func start() {
        // check if significant location monitoring is enabled
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // start listening for location changes
            locationmanager.startMonitoringSignificantLocationChanges()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // take last location as it is the most recent one
        guard let l = locations.last else { return }
        print(l)
        currentLocation = l.coordinate
        getSolarStringAndSendNotification()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func getSolarStringAndSendNotification() {
        let solar = Solar(for: Date(timeIntervalSinceNow: TimeInterval(TimeZone.current.secondsFromGMT())), coordinate: currentLocation)
        sunsetTime = (solar?.sunset)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        dateFormatter.timeZone = TimeZone.current
        let text = dateFormatter.string(from: sunsetTime)

        DispatchQueue.main.async {
            self.sunsetString.label = text
        }
        sunsetNotification.sendSunsetNotifcationwith(content: text, on: sunsetTime)
    }
}

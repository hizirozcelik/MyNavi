//
//  LocationManager.swift
//  NavigationApp
//
//  Created by HIZIR OZCELIK on 2023-10-08.
//

import Foundation
import CoreLocation
//import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // properties
    @Published var location = CLLocation()
    @Published var userTracking = true
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        startTracking()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        userTracking = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        userTracking = false
    }
    
    // delegate for CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager:CLLocationManager){
        if manager.authorizationStatus == .denied {
            userTracking = false
        } else {
            locationManager.startUpdatingLocation()
            userTracking = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        // get the current location
        if let location = locations.last {
            self.location = location
        }
    }
}


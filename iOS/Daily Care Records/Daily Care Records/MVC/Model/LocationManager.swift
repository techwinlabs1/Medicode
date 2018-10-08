//
//  LocationManager.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol LocationProtocol {
    @objc func success(locations:[CLLocation],manager:CLLocationManager)
    @objc func failed(error: Error,manager: CLLocationManager)
}

class LocationManager :NSObject,CLLocationManagerDelegate{
    static let sharedMgr = LocationManager()
    private var locationManager = CLLocationManager()
    var locDelegate : LocationProtocol?
    func request(){
        // location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    // MARK:- Location manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locDelegate?.success(locations: locations, manager: manager)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locDelegate?.failed(error: error, manager: manager)
    }
    func areLocationServicesEnabled() -> Bool{
        // check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied {
                let a = UIAlertController(title: APPNAME, message: Constants.Register.ENABLE_APP_LOCATION, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (okA) in
                    // open application settings page
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                })
                a.addAction(ok)
                let can = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                a.addAction(can)
                appWindow?.rootViewController?.present(a, animated: true, completion: nil)
                return false
            }
        } else {
            let a = UIAlertController(title: APPNAME, message: Constants.Register.ENABLE_PHONE_LOCATION, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (okA) in
                // open settings page
                UIApplication.shared.openURL(URL(string: "App-Prefs:root=Privacy&path=LOCATION")!)
            })
            a.addAction(ok)
            let can = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            a.addAction(can)
            appWindow?.rootViewController?.present(a, animated: true, completion: nil)
            return false
        }
        return true
    }
}

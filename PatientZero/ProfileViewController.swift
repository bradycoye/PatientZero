//
//  ViewController.swift
//  PatientZero
//
//  Created by Brady Coye on 3/18/16.
//  Copyright © 2016 DaemonDevelopment. All rights reserved.
//

import UIKit
import CoreLocation
import CloudKit
import Firebase


class ProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    let ref = Firebase(url:"https://popping-heat-5284.firebaseio.com")
    var userID = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        self.setupLocationManager()
        print(userID)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationManager() {
        
        // Set locationManager delegate as self
        self.locationManager.delegate = self
        
        // Set for the best location accuracy (tradeoff: uses more battery)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Get permission to access users location
        self.locationManager.requestWhenInUseAuthorization()
        
        // Start updating users location
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        let mphMultiple = 2.23693629
        
        
        var coordinate = newLocation.coordinate
        var latitude = coordinate.latitude 
        var longitude = coordinate.longitude
        
        let date = NSDate()
        var dataFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "dd-mm-yyyy HH:mm:ss"
        let dateString = dataFormatter.stringFromDate(date)
        
        
        var rootDatabase = Firebase(url:"https://popping-heat-5284.firebaseapp.com")
       

        
        let currentLocation = [
            "latitude": latitude,
            "longitude": longitude
        ]
        let instance = [dateString: currentLocation]
        let locations = ["locations": instance]
        self.ref.childByAppendingPath("users").childByAppendingPath("google:107339086243528089693").updateChildValues(locations)

        //self.ref.childByAppendingPath("users").childByAppendingPath(userID).childByAppendingPath("location").setValue(dateString)
           
         //self.ref.childByAppendingPath("users").childByAppendingPath(userID).childByAppendingPath("location").childByAppendingPath(dateString).setValue(currentLocation)
        print(userID)
        print(userID)
        print(userID)
        print(dateString)
        print(currentLocation)
        //rootDatabase.setValue(currentLocation)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    
}



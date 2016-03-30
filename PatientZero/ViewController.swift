//
//  ViewController.swift
//  PatientZero
//
//  Created by Brady Coye on 3/18/16.
//  Copyright © 2016 DaemonDevelopment. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import CloudKit
import GoogleSignIn


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager()
    let rootDatabase = Firebase(url:"https://popping-heat-5284.firebaseio.com")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var iCloudToken = ""
        
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
                self.createUser(userID)
            } else {
                print("Fetched iCloudID was nil")
            }
        }
        /*
         rootDatabase.authUser(iCloudToken, password: iCloudToken,
         withCompletionBlock: { error, authData in
         if error != nil {
         print(error)
         } else {
         print("Successfully logged in")
         }
         })
         */
        
        
        // Setup delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Attempt to sign in silently, this will succeed if
        // the user has recently been authenticated
        GIDSignIn.sharedInstance().signInSilently()
    }
    // Wire up to a button tap
    @IBAction func authenticateWithGoogle(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        ref.unauth()
    }
    // Implement the required GIDSignInDelegate methods
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Auth with Firebase
            ref.authWithOAuthProvider("google", token: user.authentication.accessToken, withCompletionBlock: { (error, authData) in
                // User is logged in!
                self.setupLocationManager()
                self.setupTimeBackground()
                
            })
        } else {
            // Don't assert this error it is commonly returned as nil
            println("\(error.localizedDescription)")
        }
    }
    // Implement the required GIDSignInDelegate methods
    // Unauth when disconnected from Google
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        ref.unauth();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
            
                complete(instance: recordID, error: nil)
            }
        }
    }
    
    func createUser(iCloudToken: String) {
        rootDatabase.authAnonymouslyWithCompletionBlock() { error, authData in
            if error != nil {
                print(error.localizedDescription)
            } else {
                print(authData)
            }
        }
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
    
    func setupTimeBackground() {
        
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
        
        let location = rootDatabase.childByAppendingPath(dateString)
        
        var currentLocation = [latitude: longitude]
        rootDatabase.setValue(currentLocation)
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



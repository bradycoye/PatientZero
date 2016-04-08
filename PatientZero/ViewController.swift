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


class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
   
    var ref: Firebase!
    
    @IBAction func signInButton(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://popping-heat-5284.firebaseio.com")
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
       
        
        GIDSignIn.sharedInstance().signInSilently()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOFReceivedNotication:", name:"Authenticated", object: nil)
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("Authenticated", object: nil)
                print(authData)
            } else {
                // No user is signed in
            }
        })

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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileViewController"
        {
            if let destinationVC = segue.destinationViewController as? ProfileViewController {
               // destinationVC.numberToDisplay = counter
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewLOADED")
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
           
            ref.authWithOAuthProvider("google", token: user.authentication.accessToken, withCompletionBlock: { (error, authData) in
                // User is logged in!
            })
            print("authenticated")
            
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        ref.unauth()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        ref.unauth()
    }
    
    func methodOFReceivedNotication(notification: NSNotification){
        self.performSegueWithIdentifier("profileViewController", sender: self)
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
        ref.authAnonymouslyWithCompletionBlock() { error, authData in
            if error != nil {
                print(error.localizedDescription)
            } else {
                print(authData)
            }
        }
    }
    
}



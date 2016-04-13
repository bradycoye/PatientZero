import UIKit
import CoreLocation
import Firebase


class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
   
    var ref: Firebase!
    var userID = ""
    
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
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileViewController"
        {
            if let destinationVC = segue.destinationViewController as? ProfileViewController {
               destinationVC.userID = self.userID
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
                
                self.userID = authData.uid
                
                let newUser = [
                    "provider": authData.provider,
                    "displayName": authData.providerData["displayName"] as? NSString as? String
                ]
                // Create a child path with a key set to the uid underneath the "users" node
                // This creates a URL path like the following:
                //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                self.ref.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid).setValue(newUser)
            })
            print("authenticated")
            
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
}


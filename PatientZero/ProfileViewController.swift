import UIKit
import CoreLocation
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
        
        let coordinate = newLocation.coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let date = NSDate()
        let dataFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "dd-mm-yyyy HH:mm:ss"
        
        let dateString = dataFormatter.stringFromDate(date)
        
        let currentLocation = [
            "latitude": latitude,
            "longitude": longitude
        ]
        let instance = [dateString: currentLocation]
        let locations = ["locations": instance]
        
        // TODO: change string to user variable
        self.ref.childByAppendingPath("users").childByAppendingPath("google:107339086243528089693").updateChildValues(locations)

        print(userID)
        print(dateString)
        print(currentLocation)
    
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



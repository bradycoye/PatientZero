import UIKit
import CoreLocation
import Firebase

class ProfileViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationManager: CLLocationManager!
    let ref = Firebase(url:"https://popping-heat-5284.firebaseio.com")
    var userID = "none"
    
    // These strings will be the data for the table view cells
    //let locations: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    var locationsTableValues: [String] = []
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func SignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        ref.unauth()
        self.performSegueWithIdentifier("signout", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        self.setupLocationManager()
        
        print(userID)
        self.nameField.text = "Brady Coye"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // register UITableViewCell for reuse
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signout"
        {
            if let destinationVC = segue.destinationViewController as? ViewController {
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
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        let coordinate = newLocation.coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let altitude = newLocation.altitude
        let accuracy = newLocation.horizontalAccuracy
        
        
        let date = NSDate()
        let dataFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "dd-mm-yyyy HH:mm:ss"
        
        let dateString = dataFormatter.stringFromDate(date)
        
        let currentLocation = [
            "latitude": latitude,
            "longitude": longitude,
            "altitude" : altitude,
            "accuracy" : accuracy
        ]
        
        let instance = [dateString: currentLocation]
        let locations = ["locations": instance]
        
        
        
        if let lastLocation = oldLocation {
           
            if newLocation.distanceFromLocation(oldLocation) > 30 {
                locationsTableValues.append("\(latitude)  \(longitude)")
                
                self.ref.childByAppendingPath("users").childByAppendingPath("google:107339086243528089693").childByAppendingPath("locations").updateChildValues(instance)
            }
        }
        
        guard let firstlocation = oldLocation else {
            locationsTableValues.append("\(latitude)  \(longitude)")
            return
        }
        
        // TODO: change string to user variable
       

        print(userID)
        print(dateString)
        print(currentLocation)
        
        
        
        
        self.tableView.reloadData()
    
    
        //manager.stopUpdatingLocation()
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
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationsTableValues.count
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel?.text = self.locationsTableValues[indexPath.row]

        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("You tapped cell number \(indexPath.row).")
    }
}



//
//  ViewController.swift
//  New Brighton Murals
//
//  Created by Ebin Pereppadan on 12/12/2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,
MKMapViewDelegate, CLLocationManagerDelegate {
     
    // MARK: Map & Location related stuff
    
    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        //generally we always want the first one (usually there's only 1 anyway)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
         
        if firstRun {
            firstRun = false
            let latDelta: CLLocationDegrees = 0.0030
            let lonDelta: CLLocationDegrees = 0.0030
            //a span defines how large an area is depicted on the map.
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
             
            //a region defines a centre and a size of area covered.
            let region = MKCoordinateRegion(center: location, span: span)
             
            //make the map show that region we just defined.
            self.myMap.setRegion(region, animated: true)
             
            //the following code is to prevent a bug which affects the zooming of the map to the user's location.
            //We have to leave a little time after our initial setting of the map's location and span,
            //before we can start centering on the user's location, otherwise the map never zooms in because the
            //intial zoom level and span are applied to the setCenter( ) method call, rather than our "requested" ones,
            //once they have taken effect on the map.
             
            //we setup a timer to set our boolean to true in 5 seconds.
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:
#selector(startUserTracking), userInfo: nil, repeats: false)
        }
         
        if startTrackingTheUser == true {
            myMap.setCenter(location, animated: true)
        }
    }
     
    //this method sets the startTrackingTheUser boolean class property to true. Once it's true,
   //subsequent calls to didUpdateLocations will cause the map to centre on the user's location.
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }
    
    //MARK: Table related stuff
    var murals:muralList? = nil

    @IBOutlet weak var theTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return murals?.newbrighton_murals.count ?? 0
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        let mainTitle = murals?.newbrighton_murals[indexPath.row].title ?? "Title Not Found"
        let currentID = murals?.newbrighton_murals[indexPath.row].id ?? "ID Not Found"
        content.text = mainTitle
        content.secondaryText = murals?.newbrighton_murals[indexPath.row].artist ?? "Artist Not Found"
        //let thumbnail = murals?.newbrighton_murals[indexPath.row].thumbnail ?? ""
        cell.contentConfiguration = content
        
        let lat = CLLocationDegrees(murals?.newbrighton_murals[indexPath.row].lat ?? "0.0")
        let lon = CLLocationDegrees(murals?.newbrighton_murals[indexPath.row].lon ?? "0.0")
        let pin = MKPointAnnotation()
        pin.title = mainTitle
        pin.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        myMap.addAnnotation(pin)
        
        let userDefaults = Foundation.UserDefaults.standard
        let storedId = userDefaults.string(forKey: "Favourite")
        if storedId == nil{
            print("empty")
        }
        else{
            if storedId == currentID{
                cell.imageView?.image = #imageLiteral(resourceName: "star.png")
            }
        }
        
        return cell
    }
    
    func updateTheTable() {
     theTable.reloadData()
    }

     
    // MARK: View related Stuff
        
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make this view controller a delegate of the Location Manager, so that it
        //is able to call functions provided in this view controller.
        locationManager.delegate = self as CLLocationManagerDelegate
        
        //set the level of accuracy for the user's location.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //Ask the location manager to request authorisation from the user. Note that this
        //only happens once if the user selects the "when in use" option. If the user
        //denies access, then your app will not be provided with details of the user's
        //location.
        locationManager.requestWhenInUseAuthorization()
        
        //Once the user's location is being provided then ask for updates when the user
        //moves around.
        locationManager.startUpdatingLocation()
        
        //configure the map to show the user's location (with a blue dot).
        myMap.showsUserLocation = true
        
        
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals") {
            let session = URLSession.shared
              session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let reportList = try decoder.decode(muralList.self, from: jsonData)
                    self.murals = reportList
                    DispatchQueue.main.async {
                        self.updateTheTable()
                    }
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
         }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let viewController = segue.destination as!popupViewController
            
            if let indexPath = self.theTable.indexPathForSelectedRow {
                viewController.fileName = murals?.newbrighton_murals[indexPath.row].images[0].filename ?? ""
                viewController.info = murals?.newbrighton_murals[indexPath.row].info ?? "Information Cannot be found"
                viewController.main = murals?.newbrighton_murals[indexPath.row].title ?? "Title Not Found"
                viewController.artist = murals?.newbrighton_murals[indexPath.row].artist ?? "Artist Not Found"
                viewController.id = murals?.newbrighton_murals[indexPath.row].id ?? "ID Not Found"
            }
        }
    }
}

extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}


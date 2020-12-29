//
//  ViewController.swift
//  PA8
//
//  This application uses a CoreLocation to find nearby places using the
//      GoogleMapsAPI.
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  Sources: App Development with Swift iOS 11 edition
//  Created by Makoto Kewish on 12/6/20.
//  Partnered with Kevin Lunden
//

import UIKit
import CoreLocation
import MBProgressHUD

class PlaceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var places = [Place]()
    var search = false
    
    // Creates a tableview outlet
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if CLLocationManager.locationServicesEnabled() {
            print("location services enabled")
            setupLocationServices()
        }
        else {
            print("location services disabled")
        }
    }
    
    /**
    Sets up location services and authorization from user

    - Parameter : nothing
    - Returns: nothing
    */
    func setupLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    /**
    Requests location of user via the GoogleMapsAPI

    - Parameter : manager, locations
    - Returns: nothing
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        let location = locations[locations.count - 1]
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        GoogleMapsAPI.location = latitude + "," + longitude
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        GoogleMapsAPI.fetchNearbyPlaces { (placesOptional) in
            if let places = placesOptional {
                print("in placeTableVC got the array back")
                self.places = places
                self.updateUI()
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    /**
    Updates tableView after fetching data

    - Parameter : nothing
    - Returns: nothing
    */
    func updateUI() {
        tableView.reloadData()
    }

    /**
    Prints error if location cannot be requested

    - Parameter : manager, error
    - Returns: nothing
    */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 0: no location
        // 1: authorization denied
        print("Error accessing locations \(error)")
    }
    
    /**
    Parses additional JSON for specific parts of the Place object

    - Parameter : tableView, section
    - Returns: Int
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return places.count
        }
        return 0
    }
    
    /**
    Updates the contents of each cell once places have been fetched.

    - Parameter : tableview, indexpath
    - Returns: table view cell
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let place = places[row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        
        cell.update(with: place, searched: search)
        
        return cell
    }
    
    /**
    Prepares a segue to PlaceDetailViewController

    - Parameter : segue, sender
    - Returns: nothing
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "DetailSegue" {
                if let placeDetailVC = segue.destination as? PlaceDetailViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let place = places[indexPath.row]
                     
                        placeDetailVC.placeOptional = place
                    }
                }
            }
        }
    }
    
    /**
    Refreshes/ updates user 's location.

    - Parameter : bar button item
    - Returns: nothing
    */
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        print("Pressed refresh button")
        
        updateUI()
        locationManager.requestLocation()
    }
    
    /**
    Calls performSearch when search bar button is selected.

    - Parameter : searchBar
    - Returns: nothing
    */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(searchBar: searchBar)
    }
    
    /**
    Performs search when user selects search on keyboard

    - Parameter : a searchBar
    - Returns: nothing
    */
    func performSearch(searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text != "" {
                GoogleMapsAPI.keyword = text
                places.removeAll()
                
                print(places.count)
                locationManager.requestLocation()
                search = true
            }
            else {
                search = false
            }
        }
        updateUI()
    }
    
    /**
    Monitors the search bar on updates.

    - Parameter : searchBar, text in search bar
    - Returns: nothing
    */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            search = false
            updateUI()
        }
    }
}

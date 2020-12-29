//
//  PlaceDetailViewController.swift
//  PA8
//
//  Created by Makoto Kewish on 12/6/20.
//
import Foundation
import UIKit

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var telephoneLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var placeOptional: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePlaceDetails()
    }
    
    /**
    Fetches and updates Place details

    - Parameter : nothing
    - Returns: nothing
    */
    func updatePlaceDetails() {
        if let place = placeOptional {
            GoogleMapsAPI.fetchDetails(place: place) { (placeOptional) in
                if let placeDetails = placeOptional {
                    print("Got details back")
                    self.placeOptional = placeDetails
                    self.displayPlace()
                }
            }
        }
    }
    
    /**
    Displays all the contents in the PlaceDetailViewController

    - Parameter :nothing
    - Returns: nothing
    */
    func displayPlace() {
        if let place = placeOptional {
            if let name = place.name, let address = place.address, let telephone = place.phone, let open = place.open, let review = place.review {//, let photo = place.photo {
                if open == true {
                    placeLabel.text = "\(name) (Open)"
                }
                else {
                    placeLabel.text = "\(name) (Closed)"
                }
                addressLabel.text = address
                telephoneLabel.text = telephone
                reviewLabel.text = review
                GoogleMapsAPI.fetchImage(place: place) { (imageOptional) in
                    if let image = imageOptional {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
}

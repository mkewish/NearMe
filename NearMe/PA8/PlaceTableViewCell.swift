//
//  PlaceTableViewCell.swift
//  PA8
//
//  Created by Makoto Kewish on 12/6/20.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var placeOptional: Place? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    Updates the table view cells

    - Parameter : a Place object, searched Boolean condition
    - Returns: nothing
    */
    func update(with place: Place, searched: Bool) {
        self.placeOptional = place
        
        if let nearbyPlace = placeOptional {
            if searched == true {
                if let nearbyName = nearbyPlace.name, let nearbyRating = nearbyPlace.rating, let nearbyVicinity = nearbyPlace.vicinity {
                    placeLabel.text = "\(nearbyName) (\(nearbyRating) ⭐️)"
                    addressLabel.text = nearbyVicinity
                }
            }
            else {
                placeLabel.text = ""
                addressLabel.text = ""
            }
        }
    }
    
    
}

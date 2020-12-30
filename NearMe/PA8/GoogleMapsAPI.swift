//
//  GoogleAPI.swift
//  PA8
//
//  Created by Makoto Kewish on 12/8/20.
//

import UIKit
import Foundation

struct GoogleMapsAPI {
   
    static let key = "<INSERT API KEY HERE>"
    static let nearbyURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    static let detailsURL = "https://maps.googleapis.com/maps/api/place/details/json"
    static let photosURL = "https://maps.googleapis.com/maps/api/place/photo"
    
    static var location: String?
    static var keyword: String?
    static var placeId: String?
    static var photoRef: String?
    static var placesArr = [Place]()
    
    /**
    Creates a URL for the GoogleMaps Nearby API using specific parameters for this assignment

    - Parameter : none
    - Returns: a URL type
    */
    static func googleURL() -> URL {
        let params = [
            "key": GoogleMapsAPI.key,
            "location": GoogleMapsAPI.location,
            "radius": "10000", // 10000 meter radius
            "keyword": GoogleMapsAPI.keyword
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: GoogleMapsAPI.nearbyURL)!
        components.queryItems = queryItems
        let url = components.url!
        return url
    }
    
    /**
    Creates a URL for the GoogleMaps Details API using specific parameters for this assignment

    - Parameter : none
    - Returns: a URL
    */
    static func findDetailURL() -> URL {
        let params = [
            "key": GoogleMapsAPI.key,
            "place_id": GoogleMapsAPI.placeId
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: GoogleMapsAPI.detailsURL)!
        components.queryItems = queryItems
        let url = components.url!
        return url
    }
    
    /**
    Creates a URL for the GoogleMaps Photo API using specific parameters for this assignment

    - Parameter : row: Int, row of the selected cell; col: Int, column of the selected cell; remove: Bool, if the line should be removed or not
    - Returns: nothing
    */
    static func findPhotosURL() -> URL {
        let params = [
            "key": GoogleMapsAPI.key,
            "maxwidth": "400",
            "photoreference": GoogleMapsAPI.photoRef
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: GoogleMapsAPI.photosURL)!
        components.queryItems = queryItems
        let url = components.url!
        return url
    }
    
    /**
     Fetches nearby places from the users location via the GoogleMaps API

     - Parameter : a completion check
     - Returns: nothing
     */
    static func fetchNearbyPlaces(completion: @escaping ([Place]?) -> Void) {
        let url = GoogleMapsAPI.googleURL()
        print("Nearbuy URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) {
            (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional {
                if let places = places(fromData: data) {
                    print("We got [NearbyPlace] with \(places.count) places")
                    DispatchQueue.main.async {
                        completion(places)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                print("Error getting the data")
            }
        }
        task.resume()
    }
    
    /**
    Parses JSON from the GoogleMaps Nearby API

    - Parameter : JSON data from GoogleMaps Nearby API
    - Returns: optional [Place]
    */
    static func places(fromData data: Data) -> [Place]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [String: Any], let resultsArray = jsonDictionary["results"] as? [[String: Any]] else {
                print("error parsing JSON")
                return nil
            }
            
            print("we got places")
        
            if !placesArr.isEmpty {
                placesArr.removeAll()
            }
            for placeObject in resultsArray {
                if let place = getPlace(fromJSON: placeObject) {
                    placesArr.append(place)
                }
            }
            if !placesArr.isEmpty {
                print("not empty")
                return placesArr
            }
        }
        catch {
            print("Error converting data to JSON \(error)")
        }
        
        return nil
    }
    
    /**
    Parses additional JSON for specific parts of the Place object

    - Parameter :  JSON object
    - Returns: optional Place
    */
    static func getPlace(fromJSON json: [String: Any]) -> Place? {
        
        guard let name = json["name"] as? String, let id = json["place_id"] as? String, let rating = json["rating"] as? Double, let vicinity = json["vicinity"] as? String, let photos = json["photos"] as? [[String: Any]], let photo = photos[0] as? [String: Any], let photoRef = photo["photo_reference"] as? String
        else {
            print("RETURNING NIL")
            return nil
        }
        return Place(id: id, name: name, vicinity: vicinity, rating: rating, photo: photoRef)
    }
    
    /**
    Fetches details of places from the users location via the GoogleMaps API

    - Parameter : a place object and a completion check
    - Returns: nothing
    */
    static func fetchDetails(place: Place, completion: @escaping (Place?) -> Void) {
        placeId = place.id
        let url = GoogleMapsAPI.findDetailURL()
        print("Details URL: \(url)")
    
        let task = URLSession.shared.dataTask(with: url) {
            (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional {
                if let details = details(place: place, fromData: data) {
                    print("We got Details!")
                    DispatchQueue.main.async {
                        completion(details)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                print("Error getting the data")
            }
        }
        task.resume()
    }
    
    /**
    Parses JSON from the GoogleMaps Details API

    - Parameter : a Place object, JSON data from GoogleMaps Details API
    - Returns: optional Place
    */
    static func details(place: Place, fromData data: Data) -> Place? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
            guard let jsonDictionary = jsonObject as? [String: Any], let resultArray = jsonDictionary["result"] as? [String: Any] else {
                print("Error parsing JSON")
                return nil
            }

            return getDetails(place: place, fromJSON: resultArray)
        }
        catch {
            print("Error converting data to JSON \(error)")
        }
            
        return nil
    }
    
    /**
    Parses additional JSON for specific parts of the Place object

    - Parameter : a Place object, JSON object
    - Returns: optional Place
    */
    static func getDetails(place: Place, fromJSON json: [String: Any]) -> Place? {
        // add optional chaining
        guard let address = json["formatted_address"] as? String, let phone = json["formatted_phone_number"] as? String, let hours = json["opening_hours"] as? [String: Any], let open = hours["open_now"] as? Bool, let reviews = json["reviews"] as? [[String: Any]], let recentReview = reviews[0] as? [String: Any], let text = recentReview["text"] as? String
        else {
            print("RETURNING NIL FROM getDetails")
            return nil
        }
        
        var detailedPlace = place
        
        detailedPlace.address = address
        detailedPlace.phone = phone
        detailedPlace.review = text
        detailedPlace.open = open
        
        return detailedPlace
    }
    
    /**
    Fetches the photo of places from the users location via the GoogleMaps API

    - Parameter : a Place object, a completion check
    - Returns: nothing
    */
    static func fetchImage(place: Place, completion: @escaping (UIImage?) -> Void) {
        photoRef = place.photo
        let url = findPhotosURL()
        print("Photos URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) {
            (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                if let error = errorOptional {
                    print("Error fetching image \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}

# NearMe

This IOS application fetches nearby places using the Google's PlaceAPI and PlaceDetailAPI based on the user's latitude and longitude coordinates via Xcode's CoreLocation framework. 

User's should be able to search specific nearby locations within a ten kilometer radius using the searchbar. Nearby places can also be searched using keywords i.e. coffee, gas station, restaurant, hotel, etc. 

Nearby locations will be organized in a table/list sorted by the shortest distance from the user. 

Selecting a nearby place will segue into a details page which will display the place's name, opening, address, telephone number, review, and image.

If the user changes location, their location can be refreshed using the refresh button.

**Note:** Must have Xcode installed and a valid Google Maps API key.

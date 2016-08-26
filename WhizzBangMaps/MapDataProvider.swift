//
//  MapDataProvider.swift
//  WhizzBangMaps
//
//  Created by Angus Johnston on 24/08/2016.
//  Copyright © 2016 AAMSCO. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON


class MapDataProvider {
	
    let googleMapsApiKey = "AIzaSyAQDFvcDP3tGIHW66tzrqBASkukWAjL5PA"

	var placesTask: NSURLSessionDataTask?
	var session: NSURLSession {
		return NSURLSession.sharedSession()
	}
	
    
	func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([MapLocation]) -> Void)) -> ()
	{
		var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)"
        
		let typesString = types.count > 0 ? types.joinWithSeparator("|") : "food"
		
		urlString += "&types=\(typesString)"
        urlString += "&key=\(googleMapsApiKey)"
        
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
		if let task = placesTask where task.taskIdentifier > 0 && task.state == .Running {
			task.cancel()
		}

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			var locationsArray = [MapLocation]()
			if let aData = data {
				let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
				if let results = json["results"].arrayObject as? [[String : AnyObject]] {
					for rawPlace in results {
						let place = MapLocation(dictionary: rawPlace, acceptedTypes: types)
						locationsArray.append(place)
					}
				}
                dispatch_async(dispatch_get_main_queue()) {
                    completion(locationsArray)
                }
            } else {
                print("Error making call to Google API \(error?.localizedDescription)")
                
            }
		}
		placesTask?.resume()
	}
	
	
}

//
//  MapAnnotation.swift
//  WhizzBangMaps
//
//  Created by Angus Johnston on 25/08/2016.
//  Copyright © 2016 AAMSCO. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
	
	let title: String?
	let locationName: String
	let coordinate: CLLocationCoordinate2D
 
	init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {

        let lat = String(coordinate.latitude)
        let lon = String(coordinate.longitude)
        
        let finalString = lat + " " + lon
        
        self.title = finalString //title
		self.locationName = locationName
		self.coordinate = coordinate
		
		super.init()
	}
 
	var subtitle: String? {
		return locationName
	}
}

//
//  ViewController.swift
//  WhizzBangMaps
//
//  Created by Angus Johnston on 24/08/2016.
//  Copyright © 2016 AAMSCO. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var map: MKMapView!
	
	var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
	let dataProvider = MapDataProvider()
	let searchRadius: Double = 1000

	var locationManager = CLLocationManager()
	var userLocation: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.requestWhenInUseAuthorization();
		
		map.delegate = self
		

	}
	override func viewWillAppear(animated: Bool) {
		determineMyCurrentLocation()
	}
	
	func determineMyCurrentLocation() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.startUpdatingLocation()
		}
	}
	
	var first = 0 //for testing
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		var userLocation = locations[0] as CLLocation
		
		first++
		// Call stopUpdatingLocation() to stop listening for location updates,
		// other wise this function will be called every time when user location changes.
		manager.stopUpdatingLocation()
		
		if (first == 1) {
			fetchNearbyPlaces(userLocation.coordinate)
			centerMapOnLocation(userLocation)
		}
		print("user latitude = \(userLocation.coordinate.latitude)")
		print("user longitude = \(userLocation.coordinate.longitude)")
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
	{
		print("Error \(error)")
	}
	
	let regionRadius: CLLocationDistance = 1000
	func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                            regionRadius * 2.0, regionRadius * 2.0)
		map.setRegion(coordinateRegion, animated: true)
	}
	
	func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
		
		dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
			
			for place: MapLocation in places {
				self.map.addAnnotation(MapAnnotation(title: place.name,locationName: place.address ,coordinate: place.coordinate))
			}
		}
	}
	

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		if let annotation = annotation as? MapAnnotation {
			
			let identifier = "pin"
			var view: MKPinAnnotationView
			
			if let dequeuedView = map.dequeueReusableAnnotationViewWithIdentifier(identifier)
				as? MKPinAnnotationView { // 2
				dequeuedView.annotation = annotation
				view = dequeuedView
			} else {
				// 3
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.calloutOffset = CGPoint(x: -5, y: 5)
				//view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
			}
			return view
		}
		return nil
	}
	
		
}


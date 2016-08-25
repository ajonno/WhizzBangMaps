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
    var firstLine = true
    
	var locationManager = CLLocationManager()
	var myLocation: CLLocation?
    
    var locationsDict = [CLLocation: Double]()

    
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
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations[0] as CLLocation
        
		manager.stopUpdatingLocation()
		
		if (firstLine) {
			fetchNearbyPlaces(myLocation!.coordinate)
			centerMapOnLocation(myLocation!)
		}
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

                let distance = place.location?.distanceFromLocation(self.myLocation!)

                //add locations into 'master' Dictionary
                self.locationsDict[place.location!] = distance
            }
            

            //*************************************************************************************
            //draw line from currentlocation to first pin
            let (firstPin, _) = (self.locationsDict.minElement {$0.1 < $1.1})!
            self.drawLines([firstPin.coordinate, self.myLocation!.coordinate])

            let numberOfPoints = self.locationsDict.count
            
            //draw line from first pin to next pin and start popping elements from the locationsDict
            var fromThisPin = firstPin
            var tempDict = [CLLocation: Double]()
            var toClosestPin: CLLocation
        
            for i in 0...(numberOfPoints - 2) {

                if (i == 0) {
                    self.locationsDict.removeValueForKey(firstPin)
                } else {
                    self.locationsDict.removeValueForKey(fromThisPin)
                }

                //now calc distance
                tempDict.removeAll()
                for (key, _) in (Array(self.locationsDict).sort {$0.1 < $1.1}) {
                    tempDict[key] = key.distanceFromLocation(fromThisPin)
                }
                
                toClosestPin = tempDict.minElement {$0.1 < $1.1}!.0
                
                //now draw a line from current loc to first item in array
                self.drawLines([fromThisPin.coordinate, toClosestPin.coordinate])
                
                fromThisPin = toClosestPin
            }
            
            //last stop - from final map point back to devices current location
            self.drawLines([fromThisPin.coordinate, self.myLocation!.coordinate])
            
        }
	}
    
    func drawLines(coordArray: [CLLocationCoordinate2D]) {
        var localcoord = [CLLocationCoordinate2D]()
        localcoord = coordArray
        let polyline = MKPolyline.init(coordinates: &localcoord, count: coordArray.count)
        self.map.addOverlay(polyline)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolyline) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blueColor()
            polyLineRenderer.lineWidth = 2.0
            
            return polyLineRenderer
        }
        let noResult = MKOverlayRenderer()
        return noResult
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
			}
			return view
		}
		return nil
	}
	
		
}


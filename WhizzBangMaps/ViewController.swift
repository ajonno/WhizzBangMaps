//
//  ViewController.swift
//  WhizzBangMaps
//
//  Created by Angus Johnston on 24/08/2016.
//  Copyright © 2016 AAMSCO. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var whizzLogo: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
	
	var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]

    let dataProvider = MapDataProvider()
	let searchRadius: Double = 1000

	var locationManager = CLLocationManager()
	var myLocation: CLLocation?
    var firstLine = true
    var locationsDict = [CLLocation: Double]()

    
    // MARK: View lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()

        map.hidden = true
        
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.requestWhenInUseAuthorization();
		
		map.delegate = self

	}

    override func viewWillAppear(animated: Bool) {
		determineMyCurrentLocation()
	}

    override func viewDidAppear(animated: Bool) {
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
        loadingLabel.hidden = true
        whizzLogo.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: WhizzBang methods

	private func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                            searchRadius * 2.0, searchRadius * 2.0)
		map.setRegion(coordinateRegion, animated: true)
	}
    
  	private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        
		dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
			
			for place: MapLocation in places {
                self.map.addAnnotation(MapAnnotation(title: place.name,locationName: place.address ,coordinate: place.coordinate))

                let distance = place.location?.distanceFromLocation(self.myLocation!)

                //add locations into 'master' Dictionary
                self.locationsDict[place.location!] = distance
            }

            self.placePinsOnMap()

        }
	}
    
    private func placePinsOnMap() {
        let numberOfAnnotationPoints = self.locationsDict.count
        var tempDict = [CLLocation: Double]()
        var toClosestPin: CLLocation

        //draw line from currentlocation to first pin
        let (firstPin, _) = (self.locationsDict.minElement {$0.1 < $1.1})!
        self.drawLines([firstPin.coordinate, self.myLocation!.coordinate])
        
        //draw line from first pin to next pin and start popping elements from the locationsDict
        var fromThisPin = firstPin
        self.locationsDict.removeValueForKey(firstPin)

        for i in 0...(numberOfAnnotationPoints - 2) {

            if (i > 0) {
                self.locationsDict.removeValueForKey(fromThisPin)
            }
            
            //calc new distances and sort
            tempDict.removeAll()
            for (key, _) in (Array(self.locationsDict).sort {$0.1 < $1.1}) {
                tempDict[key] = key.distanceFromLocation(fromThisPin)
            }
            
            toClosestPin = tempDict.minElement {$0.1 < $1.1}!.0
            
            self.drawLines([fromThisPin.coordinate, toClosestPin.coordinate])
            
            fromThisPin = toClosestPin
        }
        
        //last stop - from final map point back to devices current location
        self.drawLines([fromThisPin.coordinate, self.myLocation!.coordinate])

    }
    
    private func drawLines(coordArray: [CLLocationCoordinate2D]) {
        var localcoord = [CLLocationCoordinate2D]()
        localcoord = coordArray
        let polyline = MKPolyline.init(coordinates: &localcoord, count: coordArray.count)
        self.map.addOverlay(polyline)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    // MARK: CoreLocation methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        if (firstLine) {
            map.hidden = false
            fetchNearbyPlaces(myLocation!.coordinate)
            centerMapOnLocation(myLocation!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        whizzLogo.hidden = false
        print("Location Manager error -> \(error)")
        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func determineMyCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    // MARK: MKMapViewDelegate methods
    
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



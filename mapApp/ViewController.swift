//
//  ViewController.swift
//  mapApp
//
//  Created by Alex Hoff on 5/4/16.
//  Copyright © 2016 Alex Hoff. All rights reserved.
//


import CoreLocation
import UIKit
import MapKit
import PebbleKit

class ViewController: UIViewController, CLLocationManagerDelegate, PBPebbleCentralDelegate {
    
    
    @IBOutlet var map: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        manager.requestLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] 
        
        //your location
        let you = MKPointAnnotation()
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        //center map around user
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        you.coordinate = center
        you.title = "Your position"
        
        //friends location
        let friend = MKPointAnnotation()
        let flat = 37.3230
        let flong = -122.0322
        friend.coordinate = CLLocationCoordinate2D(latitude: flat, longitude: flong)
        friend.title = "Their position"
        
        //distance between points
        let coord1 = CLLocation(latitude: latitude, longitude: longitude);
        let coord2 = CLLocation(latitude: flat, longitude: flong)
        let dist = coord1.distanceFromLocation(coord2)
        
        //bearing calculation
        let lat1 = degreesToRadians(coord1.coordinate.latitude)
        let lon1 = degreesToRadians(coord1.coordinate.longitude)
        
        let lat2 = degreesToRadians(coord2.coordinate.latitude);
        let lon2 = degreesToRadians(coord2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let heading = atan2(y, x);
        let degrees = heading*180/M_PI
        
        
        let watch = PBPebbleCentral.defaultCentral().lastConnectedWatch()
        
        watch?.appMessagesPushUpdate([
            0 : Int(degrees),
            1 : Int(dist)
            ], onSent: { (watch, myDict, error) -> Void in
            if ((error == nil)) {
                //NSLog("Successfully sent message.");
            } else {
                NSLog("Error sending message \(error)");
            }
        })
        
        

        
        //add pins -remove old?
        map.addAnnotation(you)
        map.addAnnotation(friend)
        //let span = MKCoordinateSpanMake(0.01, 0.01)
        //let region = MKCoordinateRegion(center: center, span: span)
        //self.map.setRegion(region, animated: true)
        
        if let location = locations.first {
            print("Found user's location: \(location)")
            print("Distance from other location: \(dist) m")
            print("RallyUp heading should be: \(degrees)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }

}
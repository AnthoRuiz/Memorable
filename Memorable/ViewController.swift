//
//  ViewController.swift
//  Memorable
//
//  Created by Anthony Ruiz on 9/28/18.
//  Copyright © 2018 Jakaboy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

   @IBOutlet weak var map: MKMapView!
   var manager = CLLocationManager()
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
      
      let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:)))
      uilpgr.minimumPressDuration = 2
      map.addGestureRecognizer(uilpgr)
      
      if activePlace == -1 {
         
         manager.delegate =  self
         manager.desiredAccuracy = kCLLocationAccuracyBest
         manager.requestWhenInUseAuthorization()
         manager.startUpdatingLocation()
         
      } else {
         
         //get place details to display on map
         
         if places.count > activePlace {
            if let name = places[activePlace]["name"] {
               
               if let lat = places[activePlace]["lat"]{
                  
                  if let lon = places[activePlace]["lon"]{
                     
                     if let latitude = Double(lat) {
                        
                        if let longitude = Double(lon) {
                           
                           let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                           let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                           let region = MKCoordinateRegion(center: coordinate, span: span)
                           self.map.setRegion(region, animated: true)
                           let annotation = MKPointAnnotation()
                           annotation.coordinate = coordinate
                           annotation.title = name
                           self.map.addAnnotation(annotation)
                        }
                     }
                  }
               }
            }
         }
         
      }
   }
   
   @objc func longPress(gestureRecognizer: UIGestureRecognizer) {
      
      if gestureRecognizer.state == UIGestureRecognizer.State.began {
         
         let touchPoint = gestureRecognizer.location(in: self.map)
         
         let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
         
         let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
         var tittle = ""
         
         CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
               print(error!)
            } else {
               if let placeMark = placemarks?[0] {
                  
                  if placeMark.subThoroughfare != nil {
                     tittle += placeMark.subThoroughfare! + ""
                  }
                  
                  if placeMark.thoroughfare != nil {
                     tittle += placeMark.thoroughfare! + ""
                  }
               }
            }
            
            if tittle == "" {
               tittle = "Added \(NSDate())"
            }
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = newCoordinate
            
            annotation.title = tittle
            
            self.map.addAnnotation(annotation)
            
            places.append(["name":tittle, "lat":String(newCoordinate.latitude), "lon":String(newCoordinate.longitude)])
            
            UserDefaults.standard.set(places, forKey: "places")
         }
      
      }
   
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
      
      let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      let region = MKCoordinateRegion(center: location, span: span)
      self.map.setRegion(region, animated: true)
   }


}


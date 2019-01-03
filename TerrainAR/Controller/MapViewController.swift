//
//  ViewController.swift
//  MappAR_01
//
//  Created by Jeremy Raven on 23/09/18.
//  Copyright © 2018 Jeremy Raven. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var mapTypeSegmetedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var copyright: UILabel!
    @IBOutlet weak var forMoreInfo: UILabel!
    
    
    var zoom = true
    var rawCoordinates: CLLocationCoordinate2D!
    var coordinatesArray: [CLLocationCoordinate2D]? = []

    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        self.mapTypeSegmetedControl.addTarget(self, action: #selector(mapTypeChanged), for: .valueChanged)
        
        registerGestureRecognizers()
        
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        
        self.blurEffect.isHidden = true
        logoImage.isHidden = true
        close.isHidden = true
        copyright.isHidden = true
        forMoreInfo.isHidden = true
    }
    
    @IBAction func infomation(_ sender: UIButton) {
        
        self.blurEffect.isHidden = false
        logoImage.isHidden = false
        close.isHidden = false
        copyright.isHidden = false
        forMoreInfo.isHidden = false
    }
    
    // Clear Coordinates Array and Annotations from view
    @IBAction func clearCoordinates() {
        
        coordinatesArray?.removeAll()
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
    }
    
    //MARK: Gesture Recognizer
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    // Tapped gesture - build coordinatesArray
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
        let touchPoint = recognizer.location(in: self.mapView)
        rawCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        if (coordinatesArray?.count)! < 2 {
            coordinatesArray?.append(rawCoordinates)
        } else { return }
        
        createPointAnnotation(rawCoords: rawCoordinates)

    }
    
    //MARK: Create Annotations
    func createPointAnnotation(rawCoords: CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = rawCoords
        mapView.addAnnotation(annotation)
        
    }
    
    //MARK: Handle Segmented Controller
    @objc func mapTypeChanged(segmentedControl: UISegmentedControl) {
        
        switch(segmentedControl.selectedSegmentIndex) {
        
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if zoom {
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
        }
        zoom = false
    }
    
    //MARK: Reverse Geocoding
    // Build Alert view
    @IBAction func showAddAddressView() {
        
        let alertVC = UIAlertController(title: "Add Address", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { textField in
            
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
            
            if let textField = alertVC.textFields?.first {
                
                // reverse geocode the address
                self.reverseGeocode(address :textField.text!)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // Create CL Placemark
    private func reverseGeocode(address :String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks,error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks,
                let placemark = placemarks.first else {
                    return
            }
            
            self.addPlacemarkToMap(placemark :placemark)
            
        }
    }
    
    // Add Annotation to mapView
    private func addPlacemarkToMap(placemark :CLPlacemark) {
        
        let coordinate = placemark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        self.mapView.addAnnotation(annotation)
        
        // Zoom to the annotation location
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setRegion(region, animated: true)
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check View Controller desination
        if segue.destination is ARViewController {
            if coordinatesArray!.count < 2 {
                
                // Create alert if coordinatesArray < 2
                let alertVC = UIAlertController(title: "Wait", message: "You need to place two pins first", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                // Otherwise pass coordinatesArray to 
                let vcAR = segue.destination as? ARViewController
                // Double check array is not empty
                if !coordinatesArray!.isEmpty {
                    vcAR?.ARcoordinatesArray = coordinatesArray!
                } else {return}
            }
        } else {
            let vcTV = segue.destination as? TableViewController
            if !coordinatesArray!.isEmpty {
                vcTV?.favCoordinatesArray = coordinatesArray!
            } else {return}
        }
    }
    
}


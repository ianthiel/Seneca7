//
//  ViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/1/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var workLocationsLabel: UILabel!
    @IBOutlet weak var hoursAtOfficeThisWeekLabel: UILabel!
    
    // setup a location manager as an instance of CLLocationmManager class
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationServices()
        setupMap()
        tests()
    }
    
    func setupLocationServices() {
        // setup location stuff
        self.locationManager.delegate = self
        // we'll need accuracy to be < 10 meters since the work space may be small
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // we'll need "always" authorization to listen for when the user enters/leaves work
        locationManager.requestAlwaysAuthorization()
        // we want to begin monitoring location once the user starts the app and if we are authorized to do so
        locationManager.startUpdatingLocation()
    }
    
    func setupMap() {
        // setup map stuff
        mainMapView.delegate = self
        // we need the standard apple map, nothing fancy
        mainMapView.mapType = MKMapType.Standard
        // we want the map to display user location
        mainMapView.showsUserLocation = true
    }
    
    func tests() {
        print(locationManager.location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  AddWorkLocationViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/2/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddWorkLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var addMapView: MKMapView!
    
    @IBAction func zoomToCurrentUserLocation(sender: AnyObject) {
        zoomToUserLocationInMapView(addMapView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap(addMapView)
        delay(0.5) {
            zoomToUserLocationInMapView(self.addMapView)
        }
    }
    
}
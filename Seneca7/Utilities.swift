//
//  Utilities.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/2/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit

func zoomToUserLocationInMapView(mapView: MKMapView) {
    if let coordinate = mapView.userLocation.location?.coordinate {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func setupMap(map: MKMapView) {
    // setup map stuff
    // map.delegate = self
    // we need the standard apple map, nothing fancy
    map.mapType = MKMapType.Standard
    // we want the map to display user location
    map.showsUserLocation = true
}
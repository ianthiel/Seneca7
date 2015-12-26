//
//  Utilities.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/2/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit

func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle:  .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}

func zoomToUserLocationInMapView(mapView: MKMapView) {
    if let coordinate = mapView.userLocation.location?.coordinate {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
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
    map.mapType = MKMapType.Standard
    map.showsUserLocation = true
}

func easyRound(toRound: Double) -> Double {
    let rounded = round(toRound * 10) / 10
    return rounded
}
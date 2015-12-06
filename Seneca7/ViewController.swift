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

let kSavedItemsKey = "savedItems"

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AddWorkLocationsViewControllerDelegate {

    var workLocations = [WorkLocation]()
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var workLocationsLabel: UILabel!
    @IBOutlet weak var hoursAtOfficeThisWeekLabel: UILabel!
    @IBOutlet weak var workLocationsCountLabel: UILabel!
    @IBOutlet weak var workLocationsCountDisplay: UILabel!
    
    
    // setup a location manager as an instance of CLLocationmManager class
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationServices()
        setupMap(mainMapView)
        tests()
        delay(1.0) {
            zoomToUserLocationInMapView(self.mainMapView)
        }
        loadAllWorkLocations()
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
    
    @IBAction func onZoomToUserLocation(sender: AnyObject) {
        zoomToUserLocationInMapView(mainMapView)
    }
    
    // MARK: Saving and loading functions for workLocations
    
    func saveAllWorkLocations() {
        let items = NSMutableArray()
        for workLocation in workLocations {
            let item = NSKeyedArchiver.archivedDataWithRootObject(workLocation)
            items.addObject(item)
        }
        NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadAllWorkLocations() {
        workLocations = []
        
        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
            for savedItem in savedItems {
                if let workLocation = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? WorkLocation {
                    addWorkLocation(workLocation)
                }
            }
        }
    }
    
    // MARK: add, remove, and update functions for workLocation model changes
    
    func addWorkLocation(workLocation: WorkLocation) {
        workLocations.append(workLocation)
        mainMapView.addAnnotation(workLocation)
        // addRadiusOverlayForWorkLocation(workLocation)
        // updateWorkLocationsCount()
    }
    
    func removeWorkLocation(workLocation: WorkLocation) {
        if let indexInArray = workLocations.indexOf(workLocation) {
            workLocations.removeAtIndex(indexInArray)
        }
        
        mainMapView.removeAnnotation(workLocation)
        // removeRadiusOverlayForWorkLocation(workLocation)
        // updateWorkLocationsCount()
    }
    
    func updateWorkLocationsCount() {
        workLocationsCountDisplay.text = "\(workLocations.count)"
    }
    
    // MARK: AddWorkLocationViewControllerDelegate
    
    func addWorkLocationViewController(controller: AddWorkLocationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, name: String) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        // add workLocation
        let workLocation = WorkLocation(coordinate: coordinate, radius: radius, identifier: identifier, name: name)
        addWorkLocation(workLocation)
        saveAllWorkLocations()
    }
    
    // MARK: MKMapViewDelegate
    
    func mainMapView(mainMapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myWorkLocation"
        if annotation is WorkLocation {
            var annotationView = mainMapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .Custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteWorkLocation")!, forState: .Normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mainMapView(mainMapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer? {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }
    
    // MARK: random tests + other junk
    
    func tests() {
        print(locationManager.location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


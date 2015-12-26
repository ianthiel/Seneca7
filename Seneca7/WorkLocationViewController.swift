//
//  WorkLocationViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/25/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let kSavedItemsKey = "savedItems"

class WorkLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AddWorkLocationsViewControllerDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var hoursWorkedDisplay: UILabel!
    @IBAction func onZoomToUserLocation(sender: AnyObject) {
        zoomToUserLocationInMapView(mainMapView)
    }
    
    let locationManager = CLLocationManager()
    var workLocations = [WorkLocation]()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationServices()
        setupMap(mainMapView)
        delay(1.0) {
            zoomToUserLocationInMapView(self.mainMapView)
        }
        loadAllWorkLocations()
        mainMapView.delegate = self
        
        hoursWorkedDisplay.text = "Minutes Worked: \(String(easyRound((userDefaults.valueForKey("minutes") as! Double))))"
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addWorkLocationSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddWorkLocationViewController
            vc.delegate = self
        } else {
            return
        }
    }
    
    func setupLocationServices() {
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
        addRadiusOverlayForWorkLocation(workLocation)
        print(self.mainMapView.overlays.count)
        updateWorkLocationsCount()
    }
    
    func removeWorkLocation(workLocation: WorkLocation) {
        if let indexInArray = workLocations.indexOf(workLocation) {
            workLocations.removeAtIndex(indexInArray)
        }
        
        mainMapView.removeAnnotation(workLocation)
        removeRadiusOverlayForWorkLocation(workLocation)
        updateWorkLocationsCount()
    }
    
    func updateWorkLocationsCount() {
        title = "Work Locations: \(workLocations.count)"
        navigationItem.rightBarButtonItem?.enabled = (workLocations.count < 20)
        
    }
    
    // MARK: AddWorkLocationViewControllerDelegate
    
    func addWorkLocationViewController(controller: AddWorkLocationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, name: String) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
        // add workLocation
        let workLocation = WorkLocation(coordinate: coordinate, radius: clampedRadius, identifier: identifier, name: name)
        addWorkLocation(workLocation)
        
        startMonitoringWorkLocation(workLocation)
        
        saveAllWorkLocations()
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let workLocation = view.annotation as! WorkLocation
        stopMonitoringWorkLocation(workLocation)
        removeWorkLocation(workLocation)
        saveAllWorkLocations()
    }
    
    // MARK: Map overlay functions
    
    func addRadiusOverlayForWorkLocation(workLocation: WorkLocation) {
        mainMapView?.addOverlay(MKCircle(centerCoordinate: workLocation.coordinate, radius: workLocation.radius))
    }
    
    func removeRadiusOverlayForWorkLocation(workLocation: WorkLocation) {
        // find exactly one overlay with the same coordinates and radius to remove
        if let overlays = mainMapView?.overlays {
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    let coord = circleOverlay.coordinate
                    if coord.latitude == workLocation.coordinate.latitude && coord.longitude == workLocation.coordinate.longitude && circleOverlay.radius == workLocation.radius {
                        mainMapView?.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
    }
    
    // MARK: geofencing stuff
    
    func regionWithWorkLocation(workLocation: WorkLocation) -> CLCircularRegion {
        let region = CLCircularRegion(center: workLocation.coordinate, radius: workLocation.radius, identifier: workLocation.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func startMonitoringWorkLocation(workLocation: WorkLocation) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            return
        }
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showSimpleAlertWithTitle("Warning", message: "Your work location is saved but will only be activated once you grant permission to access the device location.", viewController: self)
        }
        let region = regionWithWorkLocation(workLocation)
        locationManager.startMonitoringForRegion(region)
    }
    
    func stopMonitoringWorkLocation(workLocation: WorkLocation) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == workLocation.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    // MARK: error handling
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    // MARK: random tests + other junk
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
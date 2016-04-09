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
import Parse
import SwiftDate
import RealmSwift

let kSavedItemsKey = "savedItems"
let realm = try! Realm()

class WorkLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AddWorkLocationsViewControllerDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
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
        
        updateStatusOfRegions()
        
        // add notification observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // Notification observer methods
    func didBecomeActive() {
        updateStatusOfRegions()
    }
    
    func updateStatusOfRegions() {
        for workLocation in workLocations {
            let region = regionWithWorkLocation(workLocation)
            self.locationManager.requestStateForRegion(region)
        }
    }
    
    // Define localDate as your currentLocale and define userID
    let localDate = NSDate().inRegion(Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())).localDate!
    let userID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    // Define function that gives the different between the last saved time and the current time
    func updateTime() -> Double {
        let savedTime = userDefaults.valueForKey("dateTime")
        let secondsPassed = NSDate().timeIntervalSinceDate(savedTime as! NSDate)
        let minutesPassed = secondsPassed / 60
        if userDefaults.valueForKey("minutes") != nil {
            let previous = userDefaults.valueForKey("minutes") as! Double
            let new = previous + minutesPassed
            userDefaults.setValue(new, forKey: "minutes")
            userDefaults.synchronize()
        } else {
            userDefaults.setValue(minutesPassed, forKey: "minutes")
            userDefaults.synchronize()
        }
        return minutesPassed
    }
    
    func updateParseYear(minutesPassed: Double) {
        
        let realmYear = RealmYear()
        
        // check if we've already captured time worked for the current week
        // if so, update time
        if realm.objects(RealmYear).filter("id = '\(self.localDate.year)'").first != nil {
            realmYear.id = "\(self.localDate.year)"
            let oldTime = realm.objects(RealmYear).filter("id = '\(self.localDate.year)'").first?.time
            let newTime = oldTime! + minutesPassed
            realmYear.time = newTime
            try! realm.write {
                realm.add(realmYear, update: true)
                print("realmYear updated with \(minutesPassed) minutes added")
            }
            // if this is a new week, create the week and add time
        } else {
            realmYear.id = "\(self.localDate.year)"
            realmYear.time = minutesPassed
            try! realm.write {
                realm.add(realmYear, update: true)
                print("realmYear created with \(minutesPassed) minutes")
            }
        }
    }
    
    func updateParseMonth(minutesPassed: Double) {
        
        let realmMonth = RealmMonth()
        
        // check if we've already captured time worked for the current week
        // if so, update time
        if realm.objects(RealmMonth).filter("id = '\(self.localDate.year).\(self.localDate.month)'").first != nil {
            realmMonth.id = "\(self.localDate.year).\(self.localDate.month)"
            let oldTime = realm.objects(RealmMonth).filter("id = '\(self.localDate.year).\(self.localDate.month)'").first?.time
            let newTime = oldTime! + minutesPassed
            realmMonth.time = newTime
            try! realm.write {
                realm.add(realmMonth, update: true)
                print("realmMonth updated with \(minutesPassed) minutes added")
            }
            // if this is a new week, create the week and add time
        } else {
            realmMonth.id = "\(self.localDate.year).\(self.localDate.month)"
            realmMonth.time = minutesPassed
            try! realm.write {
                realm.add(realmMonth, update: true)
                print("realmMonth created with \(minutesPassed) minutes")
            }
        }
    }
    
    func updateParseWeek(minutesPassed: Double) {
        
        let realmWeek = RealmWeek()
        
        // check if we've already captured time worked for the current week
        // if so, update time
        if realm.objects(RealmWeek).filter("id = '\(self.localDate.year).\(self.localDate.weekOfYear)'").first != nil {
            realmWeek.id = "\(self.localDate.year).\(self.localDate.weekOfYear)"
            let oldTime = realm.objects(RealmWeek).filter("id = '\(self.localDate.year).\(self.localDate.weekOfYear)'").first?.time
            let newTime = oldTime! + minutesPassed
            realmWeek.time = newTime
            try! realm.write {
                realm.add(realmWeek, update: true)
                print("realmWeek updated with \(minutesPassed) minutes added")
            }
            // if this is a new week, create the week and add time
        } else {
            realmWeek.id = "\(self.localDate.year).\(self.localDate.weekOfYear)"
            realmWeek.time = minutesPassed
            try! realm.write {
                realm.add(realmWeek, update: true)
                print("realmWeek created with \(minutesPassed) minutes")
            }
        }
    }
    
    func updateParseDay(minutesPassed: Double) {
        
        let realmDay = RealmDay()
        
        // check if we've already captured time worked for the current day
        // if so, update time
        if realm.objects(RealmDay).filter("id = '\(self.localDate.year).\(self.localDate.month).\(self.localDate.day)'").first != nil {
            realmDay.id = "\(self.localDate.year).\(self.localDate.month).\(self.localDate.day)"
            let oldTime = realm.objects(RealmDay).filter("id = '\(self.localDate.year).\(self.localDate.month).\(self.localDate.day)'").first?.time
            let newTime = oldTime! + minutesPassed
            realmDay.time = newTime
            try! realm.write {
                realm.add(realmDay, update: true)
                print("realmDay updated with \(minutesPassed) minutes added")
            }
        // if this is a new day, create the day and add time
        } else {
            realmDay.id = "\(self.localDate.year).\(self.localDate.month).\(self.localDate.day)"
            realmDay.time = minutesPassed
            try! realm.write {
                realm.add(realmDay, update: true)
                print("realmDay created with \(minutesPassed) minutes")
            }
        }
    }
    
    // MARK: didDetermineState handling
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        let previousState = NSUserDefaults.standardUserDefaults().valueForKey("Status") as? String
        print("previousState is \(previousState)")
        
        if state == CLRegionState.Inside {
            if previousState == "Inside" {
                print("state = Inside, previousState = Inside")
                if userDefaults.valueForKey("dateTime") != nil {
                    let savedTime = userDefaults.valueForKey("dateTime")
                    print("savedTime is \(savedTime)")
                    let secondsPassed = NSDate().timeIntervalSinceDate(savedTime as! NSDate)
                    print("secondsPassed is \(secondsPassed)")
                    let minutesPassed = secondsPassed / 60.0
                    if let previous = userDefaults.valueForKey("minutes") as? Double {
                        let new = previous + minutesPassed
                        print("previous is \(previous) and new is \(new)")
                        userDefaults.setValue(new, forKey: "minutes")
                        userDefaults.setValue(NSDate(), forKey: "dateTime")
                        userDefaults.synchronize()
                        updateParseYear(minutesPassed)
                        updateParseMonth(minutesPassed)
                        updateParseWeek(minutesPassed)
                        updateParseDay(minutesPassed)
                    } else {
                        let new = minutesPassed
                        userDefaults.setValue(new, forKey: "minutes")
                        userDefaults.setValue(NSDate(), forKey: "dateTime")
                        userDefaults.synchronize()
                        updateParseYear(minutesPassed)
                        updateParseMonth(minutesPassed)
                        updateParseWeek(minutesPassed)
                        updateParseDay(minutesPassed)
                    }
                } else {
                    userDefaults.setValue(NSDate(), forKey: "dateTime")
                    userDefaults.synchronize()
                }
            } else if previousState == "Outside" {
                print("state = Inside, previousState = Outside")
                userDefaults.setValue(NSDate(), forKey: "dateTime")
                userDefaults.setValue("Inside", forKey: "Status")
                userDefaults.synchronize()
            } else {
                print("Entered 'else' branch of inside state")
                userDefaults.setValue(NSDate(), forKey: "dateTime")
                userDefaults.setValue("Inside", forKey: "Status")
                userDefaults.synchronize()
            }
        } else if state == CLRegionState.Outside {
            if previousState == "Inside" {
                if userDefaults.valueForKey("dateTime") != nil {
                    print("state = Outside, previousState = Inside")
                    let savedTime = userDefaults.valueForKey("dateTime")
                    let secondsPassed = NSDate().timeIntervalSinceDate(savedTime as! NSDate)
                    let minutesPassed = secondsPassed / 60.0
                    let previous = userDefaults.valueForKey("minutes") as! Double
                    let new = previous + minutesPassed
                    userDefaults.setValue(new, forKey: "minutes")
                    userDefaults.setValue("Outside", forKey: "Status")
                    userDefaults.synchronize()
                    updateParseYear(minutesPassed)
                    updateParseMonth(minutesPassed)
                    updateParseWeek(minutesPassed)
                    updateParseDay(minutesPassed)
                } else {
                    // do nothing
                }
            } else if previousState == "Outside" {
                print("state = Outside, previousState = Outside")

            } else {
                userDefaults.setValue("Outside", forKey: "Status")
                userDefaults.synchronize()
            }
        } else if state == CLRegionState.Unknown {
            print("CLRegionState for \(region) was Unknown")
        } else {
            print("'didDetermineState' failed")
        }
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
        userDefaults.setObject(items, forKey: kSavedItemsKey)
        userDefaults.synchronize()
    }
    
    func loadAllWorkLocations() {
        workLocations = []
        
        if let savedItems = userDefaults.arrayForKey(kSavedItemsKey) {
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
        navigationItem.rightBarButtonItem?.enabled = (workLocations.count < 1)
        
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
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        delay(1.0) {
            self.locationManager.requestStateForRegion(region)
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
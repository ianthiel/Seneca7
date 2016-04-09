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
        // Begin Parse code for updating Year
        
        let years = PFObject(className: "Years")
        let yearsQuery = PFQuery(className:"Years")
        yearsQuery.whereKey("UserID", equalTo:userID)
        yearsQuery.orderByDescending("createdAt")
        yearsQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in

            if error != nil {
                print("Error: \(error)")
                if error!.code == 101 {
                    years["UserID"] = self.userID
                    years["Year"] = self.localDate.year
                    years["Time"] = minutesPassed
                    years.saveInBackground()
                    print("ParseYear created")
                }
            } else if object == nil {
                years["UserID"] = self.userID
                years["Year"] = "\(self.localDate.year)"
                years["Time"] = minutesPassed
                years.saveInBackground()
                print("ParseYear created")
            } else if object!.valueForKey("Year") as! Int == self.localDate.year {
                let newTime = object!.valueForKey("Time") as! Double + minutesPassed
                object!.setValue(newTime, forKey: "Time")
                object!.saveInBackground()
                print("ParseYear updated")
            } else {
                years["UserID"] = self.userID
                years["Year"] = "\(self.localDate.year)"
                years["Time"] = minutesPassed
                years.saveInBackground()
                print("ParseYear created")
            }
        }
    }
    
    func updateParseMonth(minutesPassed: Double) {
        
        let months = PFObject(className: "Months")
        let monthsQuery = PFQuery(className:"Months")
        monthsQuery.whereKey("UserID", equalTo:userID)
        monthsQuery.orderByDescending("createdAt")
        monthsQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print("Error: \(error)")
                if error!.code == 101 {
                    months["UserID"] = self.userID
                    months["Month"] = "\(self.localDate.year).\(self.localDate.month)"
                    months["Time"] = minutesPassed
                    months.saveInBackground()
                    print("ParseMonth created")
                }
            } else if object == nil {
                months["UserID"] = self.userID
                months["Month"] = "\(self.localDate.year).\(self.localDate.month)"
                months["Time"] = minutesPassed
                months.saveInBackground()
                print("ParseMonth created")
            } else if object!.valueForKey("Month") as! String == "\(self.localDate.year).\(self.localDate.month)" {
                let newTime = object!.valueForKey("Time") as! Double + minutesPassed
                object!.setValue(newTime, forKey: "Time")
                object!.saveInBackground()
                print("ParseMonth updated")
            } else {
                months["UserID"] = self.userID
                months["Month"] = "\(self.localDate.year).\(self.localDate.month)"
                months["Time"] = minutesPassed
                months.saveInBackground()
                print("ParseMonth created")
            }
        }
    }
    
    func updateParseWeek(minutesPassed: Double) {
        
        let weeks = PFObject(className: "Weeks")
        let weeksQuery = PFQuery(className:"Weeks")
        weeksQuery.whereKey("UserID", equalTo:userID)
        weeksQuery.orderByDescending("createdAt")
        weeksQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print("Error: \(error)")
                if error!.code == 101 {
                    weeks["UserID"] = self.userID
                    weeks["Week"] = "\(self.localDate.year).\(self.localDate.weekOfYear)"
                    weeks["Time"] = minutesPassed
                    weeks.saveInBackground()
                    print("ParseWeek created")
                }
            } else if object == nil {
                weeks["UserID"] = self.userID
                weeks["Week"] = "\(self.localDate.year).\(self.localDate.weekOfYear)"
                weeks["Time"] = minutesPassed
                weeks.saveInBackground()
                print("ParseWeek created")
            } else if object!.valueForKey("Week") as! String == "\(self.localDate.year).\(self.localDate.weekOfYear)" {
                let newTime = object!.valueForKey("Time") as! Double + minutesPassed
                object!.setValue(newTime, forKey: "Time")
                object!.saveInBackground()
                print("ParseWeek updated")
            } else {
                weeks["UserID"] = self.userID
                weeks["Week"] = "\(self.localDate.year).\(self.localDate.weekOfYear)"
                weeks["Time"] = minutesPassed
                weeks.saveInBackground()
                print("ParseWeek created")
            }
        }
    }
    
    func updateParseDay(minutesPassed: Double) {
        
        let realmDay = RealmDay()
        realmDay.id = Int("\(self.localDate.year)\(self.localDate.month)\(self.localDate.day)")
        realmDay.time = minutesPassed
        print(realmDay.id)
        print(realmDay.time)
        try! realm.write {
            realm.add(realmDay, update: true)
        }
    }
    
    // MARK: didDetermineState handling
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        let previousState = NSUserDefaults.standardUserDefaults().valueForKey("Status") as? String
        print("previousState is \(previousState)")
        
        if state == CLRegionState.Inside {
            logParseWorkEvent("Inside")
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
            logParseWorkEvent("Outside")
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
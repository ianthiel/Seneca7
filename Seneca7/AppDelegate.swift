//
//  AppDelegate.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/1/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Bolts
import SwiftDate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveTime(dateTime: NSDate) {
        userDefaults.setValue(dateTime, forKey: "dateTime")
        userDefaults.synchronize()
        if userDefaults.valueForKey("dateTime") == nil {
            print("No dateTime set")
        } else {
            print(userDefaults.valueForKey("dateTime")!)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // MARK: Parse setup
        Parse.enableLocalDatastore()
        Parse.setApplicationId("40EKKWRWCZnJFP72EwpYXs404d8IqXveNtN1z3Vb", clientKey: "rJvQIObidRjZL59IMbKGbtKhhvmmvcgENaDW3NPD")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        return true
    }
    
    func handleRegionEvent(region: CLRegion!, type: String) {
        if UIApplication.sharedApplication().applicationState == .Active {
            if let message = noteFromRegionIdentifier(region.identifier) {
                if let viewController = window?.rootViewController {
                    showSimpleAlertWithTitle(nil, message: "\(type) \(message)!", viewController: viewController)
                }
            }
        } else {
            let notification = UILocalNotification()
            notification.alertBody = "\(type) \(noteFromRegionIdentifier(region.identifier)!)"
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    // MARK: locationManager delegate methods
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            let date = NSDate()
            handleRegionEvent(region, type: "You have entered")
            saveTime(date)
            print("Saved time \(userDefaults.valueForKey("dateTime")!) upon entering")
            
            // MARK: Parse logging
            let workEvent = PFObject(className: "WorkEvent")
            workEvent["EventDateTime"] = NSDate()
            workEvent["UserID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
            workEvent["EventType"] = "Enter"
            workEvent.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in print("WorkEvent enter object has been saved.")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            
            let date = NSDate()
            let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
            let localDate = date.inRegion(userRegion).localDate!
            
            handleRegionEvent(region, type: "You have exited")
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
            
            // MARK: Parse constants
            
            let userID = UIDevice.currentDevice().identifierForVendor!.UUIDString
            
            // MARK: Parse logging
            let workEvent = PFObject(className: "WorkEvent")
            workEvent["EventDateTime"] = NSDate()
            workEvent["UserID"] = userID
            workEvent["EventType"] = "Exit"
            workEvent.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in print("WorkEvent exit object has been saved.")
            }
            
            // MARK: Begin Parse TIME logging
            
            // MARK: Begin Parse YEAR logging
            
            let years = PFObject(className: "Years")
            let yearsQuery = PFQuery(className:"Years")
            yearsQuery.whereKey("UserID", equalTo:userID)
            yearsQuery.orderByDescending("createdAt")
            yearsQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                
                if error != nil {
                    print("Error: \(error)")
                } else if object == nil {
                    years["UserID"] = userID
                    years["Year"] = localDate.year
                    years["Time"] = minutesPassed
                    years.saveInBackground()
                } else if object!.valueForKey("Year") as! Int == localDate.year {
                    let newTime = object!.valueForKey("Time") as! Double + minutesPassed
                    object!.setValue(newTime, forKey: "Time")
                    object!.saveInBackground()
                } else {
                    years["UserID"] = userID
                    years["Day"] = localDate.year
                    years["Time"] = minutesPassed
                    years.saveInBackground()
                }
            }
            
            // MARK: Begin Parse DAY logging

            let days = PFObject(className: "Days")
            let daysQuery = PFQuery(className:"Days")
            daysQuery.whereKey("UserID", equalTo:userID)
            daysQuery.orderByDescending("createdAt")
            daysQuery.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                
                if error != nil {
                    print("Error: \(error)")
                } else if object == nil {
                    days["UserID"] = userID
                    days["Day"] = "\(localDate.year).\(localDate.month).\(localDate.day)"
                    days["Time"] = minutesPassed
                    days.saveInBackground()
                } else if object!.valueForKey("Day") as! String == "\(localDate.year).\(localDate.month).\(localDate.day)" {
                    let newTime = object!.valueForKey("Time") as! Double + minutesPassed
                    object!.setValue(newTime, forKey: "Time")
                    object!.saveInBackground()
                } else {
                    days["UserID"] = userID
                    days["Day"] = "\(localDate.year).\(localDate.month).\(localDate.day)"
                    days["Time"] = minutesPassed
                    days.saveInBackground()
                }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func noteFromRegionIdentifier(identifier: String) -> String? {
        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
            for savedItem in savedItems {
                if let workLocation = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? WorkLocation {
                    if workLocation.identifier == identifier {
                        return workLocation.name
                    }
                }
            }
        }
        return nil
    }


}


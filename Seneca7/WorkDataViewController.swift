//
//  WorkDataViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/25/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import Parse
import SwiftDate
import CoreLocation

class WorkDataViewController: UIViewController {
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var hoursWorkedThisYearDisplay: UILabel!
    @IBOutlet weak var hoursWorkedThisMonthDisplay: UILabel!
    @IBOutlet weak var hoursWorkedThisWeekDisplay: UILabel!
    @IBOutlet weak var hoursWorkedTodayDisplay: UILabel!
    @IBOutlet weak var hoursWorkedDisplay: UILabel!
    
    let locationManager = CLLocationManager()
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    let userID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertHoursToHoursMinutesAndPrint()
        displayHoursWorkedThisYear()
        displayHoursWorkedThisMonth()
        displayHoursWorkedThisWeek()
        displayHoursWorkedToday()
    }
    
    func convertHoursToHoursMinutesAndPrint() {
        if let minutesWorkedTotal = userDefaults.valueForKey("minutes") as? Double {
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                hoursWorkedDisplay.text = "All time: \(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                hoursWorkedDisplay.text = "All time: \(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                hoursWorkedDisplay.text = "All time: \(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                hoursWorkedDisplay.text = "All time: \(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    func displayHoursWorkedToday() {
        
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let query = PFQuery(className: "Days")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Day") as! String != "\(localDate.year).\(localDate.month).\(localDate.day)" {
                            
                        } else {
                            let minutesWorkedTotal = object.valueForKey("Time")! as! Double
                            let hoursWorkedTotal = minutesWorkedTotal / 60.0
                            let hoursWorked = Int(floor(hoursWorkedTotal))
                            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
                            if hoursWorked == 1 && minutesWorked == 1 {
                                self.hoursWorkedTodayDisplay.text = "Today: \(hoursWorked) hour and \(minutesWorked) minute at work."
                            } else if hoursWorked == 1 {
                                self.hoursWorkedTodayDisplay.text = "Today: \(hoursWorked) hour and \(minutesWorked) minutes at work."
                            } else if minutesWorked == 1 {
                                self.hoursWorkedTodayDisplay.text = "Today: \(hoursWorked) hours and \(minutesWorked) minute at work."
                            } else {
                                self.hoursWorkedTodayDisplay.text = "Today: \(hoursWorked) hours and \(minutesWorked) minutes at work."
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func displayHoursWorkedThisWeek() {
        
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let query = PFQuery(className: "Weeks")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Week") as! String != "\(localDate.year).\(localDate.weekOfYear)" {
                            
                        } else {
                            let minutesWorkedTotal = object.valueForKey("Time")! as! Double
                            let hoursWorkedTotal = minutesWorkedTotal / 60.0
                            let hoursWorked = Int(floor(hoursWorkedTotal))
                            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
                            if hoursWorked == 1 && minutesWorked == 1 {
                                self.hoursWorkedThisWeekDisplay.text = "This Week: \(hoursWorked) hour and \(minutesWorked) minute at work."
                            } else if hoursWorked == 1 {
                                self.hoursWorkedThisWeekDisplay.text = "This Week: \(hoursWorked) hour and \(minutesWorked) minutes at work."
                            } else if minutesWorked == 1 {
                                self.hoursWorkedThisWeekDisplay.text = "This Week: \(hoursWorked) hours and \(minutesWorked) minute at work."
                            } else {
                                self.hoursWorkedThisWeekDisplay.text = "This Week: \(hoursWorked) hours and \(minutesWorked) minutes at work."
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func displayHoursWorkedThisMonth() {
        
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let query = PFQuery(className: "Months")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Month") as! String != "\(localDate.year).\(localDate.month)" {
                            
                        } else {
                            let minutesWorkedTotal = object.valueForKey("Time")! as! Double
                            let hoursWorkedTotal = minutesWorkedTotal / 60.0
                            let hoursWorked = Int(floor(hoursWorkedTotal))
                            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
                            if hoursWorked == 1 && minutesWorked == 1 {
                                self.hoursWorkedThisMonthDisplay.text = "This Month: \(hoursWorked) hour and \(minutesWorked) minute at work."
                            } else if hoursWorked == 1 {
                                self.hoursWorkedThisMonthDisplay.text = "This Month: \(hoursWorked) hour and \(minutesWorked) minutes at work."
                            } else if minutesWorked == 1 {
                                self.hoursWorkedThisMonthDisplay.text = "This Month: \(hoursWorked) hours and \(minutesWorked) minute at work."
                            } else {
                                self.hoursWorkedThisMonthDisplay.text = "This Month: \(hoursWorked) hours and \(minutesWorked) minutes at work."
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func displayHoursWorkedThisYear() {
        
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let query = PFQuery(className: "Years")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Year") as! Int != localDate.year {
                        } else {
                            let minutesWorkedTotal = object.valueForKey("Time")! as! Double
                            let hoursWorkedTotal = minutesWorkedTotal / 60.0
                            let hoursWorked = Int(floor(hoursWorkedTotal))
                            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
                            if hoursWorked == 1 && minutesWorked == 1 {
                                self.hoursWorkedThisYearDisplay.text = "This Year: \(hoursWorked) hour and \(minutesWorked) minute at work."
                            } else if hoursWorked == 1 {
                                self.hoursWorkedThisYearDisplay.text = "This Year: \(hoursWorked) hour and \(minutesWorked) minutes at work."
                            } else if minutesWorked == 1 {
                                self.hoursWorkedThisYearDisplay.text = "This Year: \(hoursWorked) hours and \(minutesWorked) minute at work."
                            } else {
                                self.hoursWorkedThisYearDisplay.text = "This Year: \(hoursWorked) hours and \(minutesWorked) minutes at work."
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
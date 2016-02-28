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
import SwiftCharts

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
    
    private var chart: Chart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertHoursToHoursMinutesAndPrint()
        displayHoursWorkedThisYear()
        displayHoursWorkedThisMonth()
        displayHoursWorkedThisWeek()
        displayHoursWorkedToday()
        
        setupChart()
    }
    
    func getHoursForDate(date: String) -> Double {
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        var hoursWorked = 0.0
        
        let query = PFQuery(className: "Days")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Day") as! String == date {
                            let hoursWorked = (object.valueForKey("Time")! as! Double) / 60.0
                        } else if object.valueForKey("Day") as! String == "\(localDate.year).\(localDate.month).\(localDate.day - 1)" {
                            let hoursWorked = (object.valueForKey("Time")! as! Double) / 60.0
                        }
                    }
                }
            } else if error!.code == 101 {
                print("Error 101")
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        return hoursWorked
    }
    
    func setupChart() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 24, by: 2)
        )
        
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        var tZeroWorked = 0.0
        var tMinusOneWorked = 0.0
        
        let query = PFQuery(className: "Days")
        query.whereKey("UserID", equalTo: userID)
        query.limit = 7
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("Day") as! String == "\(localDate.year).\(localDate.month).\(localDate.day)" {
                            tZeroWorked = (object.valueForKey("Time")! as! Double) / 60.0
                            print("tZeroWorked set")
                        } else if object.valueForKey("Day") as! String == "\(localDate.year).\(localDate.month).\(localDate.day - 1)" {
                            tMinusOneWorked = (object.valueForKey("Time")! as! Double) / 60.0
                            print("tMinuesOneWorked set as \(tMinusOneWorked)")
                        }
                    }
                }
            } else if error!.code == 101 {
                self.hoursWorkedTodayDisplay.text = "Today: 0 hours and 0 minutes at work."
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                // Display zero. Might be better to show the user an error message here.
                self.hoursWorkedTodayDisplay.text = "Today: 0 hours and 0 minutes at work."
            }
        }
        
        let chart = BarsChart(
            frame: CGRectMake(10, 70, 350, 350),
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            bars: [
                ("t-6", 12),
                ("t-5", 4.5),
                ("t-4", 9),
                ("t-3", 5.4),
                ("t-2", 6.8),
                ("t-1", tMinusOneWorked),
                ("t0", tZeroWorked)
            ],
            color: UIColor.redColor(),
            barWidth: 20
        )
        
        print(tMinusOneWorked)
        
        self.view.addSubview(chart.view)
        self.chart = chart
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
            } else if error!.code == 101 {
                self.hoursWorkedTodayDisplay.text = "Today: 0 hours and 0 minutes at work."
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
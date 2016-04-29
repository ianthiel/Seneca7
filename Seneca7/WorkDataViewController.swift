//
//  WorkDataViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/25/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import SwiftDate
import CoreLocation
import SwiftCharts
import RealmSwift

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
    let realm = try! Realm()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
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

    func setupChart() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 24, by: 2)
        )
        
        let chart = BarsChart(
            frame: CGRectMake(10, 80, 375, 375),
            chartConfig: chartConfig,
            xTitle: "Day",
            yTitle: "Hours Worked",
            bars: [
                (weekdayNameAtDayIndex(-6), hoursWorkedAtDayIndex(-6)),
                (weekdayNameAtDayIndex(-5), hoursWorkedAtDayIndex(-5)),
                (weekdayNameAtDayIndex(-4), hoursWorkedAtDayIndex(-4)),
                (weekdayNameAtDayIndex(-3), hoursWorkedAtDayIndex(-3)),
                (weekdayNameAtDayIndex(-2), hoursWorkedAtDayIndex(-2)),
                (weekdayNameAtDayIndex(-1), hoursWorkedAtDayIndex(-1)),
                (weekdayNameAtDayIndex(0), hoursWorkedAtDayIndex(0))
            ],
            color: UIColor.blueColor(),
            barWidth: 20
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
        
        print("Finished SetupChart()")
    }
    
    func weekdayNameAtDayIndex(dayIndex: Int) -> String {
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        let localDateAtDayIndex = localDate+dayIndex.days
        switch localDateAtDayIndex.weekday {
        case 1:
            return "Su"
        case 2:
            return "M"
        case 3:
            return "T"
        case 4:
            return "W"
        case 5:
            return "Th"
        case 6:
            return "F"
        case 7:
            return "S"
        default:
            return "Error"
        }
    }
    
    func hoursWorkedAtDayIndex(dayIndex: Int) -> Double {
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        if realm.objects(RealmDay).filter("id = '\(localDate.year).\(localDate.month).\(localDate.day+dayIndex)'").first != nil {
            return realm.objects(RealmDay).filter("id = '\(localDate.year).\(localDate.month).\(localDate.day+dayIndex)'").first!.time / 60.0
        } else {
            return 0.0
        }
    }
    
    func convertHoursToHoursMinutesAndPrint() {
        if let minutesWorkedTotal = userDefaults.valueForKey("minutes") as? Double {
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                hoursWorkedDisplay.text = "All time:\t\t\(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                hoursWorkedDisplay.text = "All time:\t\t\(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                hoursWorkedDisplay.text = "All time:\t\t\(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                hoursWorkedDisplay.text = "All time:\t\t\(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    // MARK: Begin functions that display time worked below the graph
    
    func displayHoursWorkedToday() {
        print("Start displayHoursWorkedToday")
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        // Query Realm for the current realmDay
        let realmDay = realm.objects(RealmDay).filter("id = '\(localDate.year).\(localDate.month).\(localDate.day)'").first
        // If realmDay is nil, we haven't tracked an work hours for today. In this case, display 0.
        if realmDay == nil {
            self.hoursWorkedTodayDisplay.text = "Today:\t\t0 hours and 0 minutes at work."
        } else {
            // If realmDay is not nil, we've tracked work hours for this day
            let minutesWorkedTotal = realmDay!.time
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                self.hoursWorkedTodayDisplay.text = "Today:\t\t\(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                self.hoursWorkedTodayDisplay.text = "Today:\t\t\(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                self.hoursWorkedTodayDisplay.text = "Today:\t\t\(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                self.hoursWorkedTodayDisplay.text = "Today:\t\t\(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    func displayHoursWorkedThisWeek() {
        print("Start displayHoursWorkedThisWeek")
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let realmWeek = realm.objects(RealmWeek).filter("id = '\(localDate.year).\(localDate.weekOfYear)'").first
        if realmWeek == nil {
            self.hoursWorkedThisWeekDisplay.text = "This Week:\t0 hours and 0 minutes at work."
        } else {
            let minutesWorkedTotal = realmWeek!.time
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                self.hoursWorkedThisWeekDisplay.text = "This Week:\t\(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                self.hoursWorkedThisWeekDisplay.text = "This Week:\t\(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                self.hoursWorkedThisWeekDisplay.text = "This Week:\t\(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                self.hoursWorkedThisWeekDisplay.text = "This Week:\t\(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    func displayHoursWorkedThisMonth() {
        print("Start displayHoursWorkedThisMonth")
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let realmMonth = realm.objects(RealmMonth).filter("id = '\(localDate.year).\(localDate.month)'").first
        if realmMonth == nil {
            self.hoursWorkedThisMonthDisplay.text = "This Month:\t0 hours and 0 minutes at work."
        } else {
            let minutesWorkedTotal = realmMonth!.time
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                self.hoursWorkedThisMonthDisplay.text = "This Month:\t\(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                self.hoursWorkedThisMonthDisplay.text = "This Month:\t\(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                self.hoursWorkedThisMonthDisplay.text = "This Month:\t\(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                self.hoursWorkedThisMonthDisplay.text = "This Month:\t\(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    func displayHoursWorkedThisYear() {
        print("Start displayHoursWorkedThisYear")
        let date = NSDate()
        let userRegion = Region(calType: CalendarType.Gregorian, loc: NSLocale.currentLocale())
        let localDate = date.inRegion(userRegion).localDate!
        
        let realmYear = realm.objects(RealmYear).filter("id = '\(localDate.year)'").first
        if realmYear == nil {
            self.hoursWorkedThisYearDisplay.text = "This Year:\t0 hours and 0 minutes at work."
        } else {
            let minutesWorkedTotal = realmYear!.time
            let hoursWorkedTotal = minutesWorkedTotal / 60.0
            let hoursWorked = Int(floor(hoursWorkedTotal))
            let minutesWorked = Int(floor(minutesWorkedTotal % 60.0))
            if hoursWorked == 1 && minutesWorked == 1 {
                self.hoursWorkedThisYearDisplay.text = "This Year:\t\(hoursWorked) hour and \(minutesWorked) minute at work."
            } else if hoursWorked == 1 {
                self.hoursWorkedThisYearDisplay.text = "This Year:\t\(hoursWorked) hour and \(minutesWorked) minutes at work."
            } else if minutesWorked == 1 {
                self.hoursWorkedThisYearDisplay.text = "This Year:\t\(hoursWorked) hours and \(minutesWorked) minute at work."
            } else {
                self.hoursWorkedThisYearDisplay.text = "This Year:\t\(hoursWorked) hours and \(minutesWorked) minutes at work."
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//
//  WorkDataViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/25/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit

class WorkDataViewController: UIViewController {
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var hoursWorkedDisplay: UILabel!
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertHoursToHoursMinutesAndPrint()
    }
    
    func convertHoursToHoursMinutesAndPrint() {
        let minutesWorkedTotal = userDefaults.valueForKey("minutes") as! Double
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
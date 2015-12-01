//
//  ViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/1/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mainMapView: MKMapView!
    
    @IBOutlet weak var workLocationsLabel: UILabel!
    
    @IBOutlet weak var hoursAtOfficeThisWeekLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello World")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


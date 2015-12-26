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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
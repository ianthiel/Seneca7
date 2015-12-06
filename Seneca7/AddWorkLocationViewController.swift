//
//  AddWorkLocationViewController.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/2/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol AddWorkLocationsViewControllerDelegate {
    func addWorkLocationViewController(controller: AddWorkLocationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, name: String)
}

class AddWorkLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var RadiusLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        saveButton.enabled = !radiusTextField.text!.isEmpty && !nameTextField.text!.isEmpty
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction private func onSave(sender: AnyObject) {
        let coordinate = addMapView.centerCoordinate
        let radius = Double(radiusTextField.text!)
        let identifier = NSUUID().UUIDString
        let name = nameTextField.text
        delegate!.addWorkLocationViewController(self, didAddCoordinate: coordinate, radius: radius!, identifier: identifier, name: name!)
    }
    
    @IBOutlet weak var addMapView: MKMapView!
    
    @IBAction func zoomToCurrentUserLocation(sender: AnyObject) {
        zoomToUserLocationInMapView(addMapView)
    }
    
    var delegate: AddWorkLocationsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [saveButton]
        saveButton.enabled = false
        
        setupMap(addMapView)
        delay(0.5) {
            zoomToUserLocationInMapView(self.addMapView)
        }
    }
    
}
//
//  WorkLocation.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/6/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let kWorkLocationLatitudeKey = "latitude"
let kWorkLocationLongitudeKey = "longitude"
let kWorkLocationRadiusKey = "radius"
let kWorkLocationIdentifierKey = "identifier"
let kWorkLocationNameKey = "name"

class WorkLocation: NSObject, NSCoding, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var name: String
    
    var title: String? {
        if name.isEmpty {
            return "No Name"
        }
        return name
    }
    
    var subtitle: String? {
        return "Radius: \(radius)m"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, name: String) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.name = name
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDoubleForKey(kWorkLocationLatitudeKey)
        let longitude = decoder.decodeDoubleForKey(kWorkLocationLongitudeKey)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDoubleForKey(kWorkLocationRadiusKey)
        identifier = decoder.decodeObjectForKey(kWorkLocationIdentifierKey) as! String
        name = decoder.decodeObjectForKey(kWorkLocationNameKey) as! String
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(coordinate.latitude, forKey: kWorkLocationLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kWorkLocationLongitudeKey)
        coder.encodeDouble(radius, forKey: kWorkLocationRadiusKey)
        coder.encodeObject(identifier, forKey: kWorkLocationIdentifierKey)
        coder.encodeObject(name, forKey: kWorkLocationNameKey)
    }
}
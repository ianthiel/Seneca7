//
//  WorkWeek.swift
//  Seneca7
//
//  Created by Ian Thiel on 12/6/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import UIKit

let kWorkWeekNumber = "number"
let kWorkWeekHours = "hours"
let kWorkWeekAverageHours = "average"
let kWorkWeekIdentifier = "identifier"

class WorkWeek: NSObject, NSCoding {
    var number: Int32
    var hours: Double
    var average: Double
    var identifier: String
    
    init(number: Int32, hours: Double, average: Double, identifier: String) {
        self.number = number
        self.hours = hours
        self.average = average
        self.identifier = identifier
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        number = decoder.decodeInt32ForKey(kWorkWeekNumber)
        hours = decoder.decodeDoubleForKey(kWorkWeekHours)
        average = decoder.decodeDoubleForKey(kWorkWeekAverageHours)
        identifier = decoder.decodeObjectForKey(kWorkWeekIdentifier) as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt32(number, forKey: kWorkWeekNumber)
        coder.encodeDouble(hours, forKey: kWorkWeekHours)
        coder.encodeDouble(average, forKey: kWorkWeekAverageHours)
        coder.encodeObject(identifier, forKey: kWorkWeekIdentifier)
    }
    
}

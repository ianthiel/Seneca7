//
//  Day.swift
//  Seneca7
//
//  Created by Ian Thiel on 4/7/16.
//  Copyright © 2016 Ian Thiel. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDay: Object {
    dynamic var id = ""
    dynamic var time = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

//
//  Seneca7Tests.swift
//  Seneca7Tests
//
//  Created by Ian Thiel on 12/1/15.
//  Copyright © 2015 Ian Thiel. All rights reserved.
//

import XCTest
@testable import Seneca7

class Seneca7Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationCaptured() {
        XCTAssertEqual(1+1,2, "1+1 should equal 2")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

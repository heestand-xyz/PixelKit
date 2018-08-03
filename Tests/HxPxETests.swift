//
//  HxPxETests.swift
//  HxPxETests
//
//  Created by Hexagons on 2018-07-19.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import XCTest
@testable import HxPxE

class HxPxETests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testHxPxE() {
        XCTAssert(HxPxE.main.aLive)
    }
    
    func testPIXs() {
        let cameraPIX = CameraPIX()
        XCTAssert(cameraPIX.allGood)
        let levelsPIX = LevelsPIX()
        XCTAssert(levelsPIX.allGood)
    }
    
}

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
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testALive() {
        self.measure {
            XCTAssert(HxPxE.main.aLive)
        }
    }
    
    func testPIXs() {
        let cameraPIX = CameraPIX()
        XCTAssert(cameraPIX.allGood)
        let levelsPIX = LevelsPIX()
        XCTAssert(levelsPIX.allGood)
    }
    
    func testIO() {
        let cameraPIX = CameraPIX()
        cameraPIX.camera = .front
        let levelsPIX = LevelsPIX()
        levelsPIX.inverted = true
        levelsPIX.inPix = cameraPIX
        XCTAssertThrowsError(try HxPxE.main.export(as: "Test"))
    }
    
}

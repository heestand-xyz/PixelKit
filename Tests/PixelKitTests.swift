//
//  PixelKitTests.swift
//  PixelKitTests
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import XCTest
import Cocoa
import LiveValues
import RenderKit
import PixelKit_macOS

class PixelKitTests: XCTestCase {
    
    var testPix: (PIX & NODEOut)!
    var testPixA: (PIX & NODEOut)!
    var testPixB: (PIX & NODEOut)!

    override func setUp() {
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        
        PixelKit.main.render.engine.renderMode = .manual
        
        (testPix, testPixA, testPixB) = Files.makeTestPixs()
        
    }

    override func tearDown() {}

    func testAveragePixGenerators() {
        
        /// 8bit at 128x128
        let averages: [AutoPIXGenerator: CGFloat] = [
            .arcpix: 0.047119140625,
            .circlepix: 0.197021484375,
            .colorpix: 1.0,
            .gradientpix: 0.5,
            .linepix: 0.0115966796875,
            .noisepix: 0.4070302925856992,
            .polygonpix: 0.16357421875,
            .rectanglepix: 0.19140625
        ]
        
        for average in averages {
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            
            print("testing", average.key.name)
            let pix = average.key.pixType.init(at: ._128)
                    
            let expect = XCTestExpectation()
            try! PixelKit.main.render.engine.manuallyRender {
                guard let pixels = pix.renderedPixels else {
                    XCTAssert(false);
                    expect.fulfill();
                    return
                }
                let lum = pixels.average.lum.cg
                print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", lum)
                XCTAssert(lum == average.value, "\(average.key.name) average should be \(average.value) and was \(lum)")
                expect.fulfill()
            }
            self.wait(for: [expect], timeout: 1.0)
            
            pix.destroy()
            
        }
        
    }

    func testShapePixGenerators() {
        
        let shapes: [AutoPIXGenerator: String] = [
            .arcpix: """
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            """,
            .circlepix: """
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            """,
            .colorpix: """
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            ⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️
            """,
            .linepix: """
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            """,
            .noisepix: """
            ◻️◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◻️◽️◽️◽️◽️◽️▫️▫️◽️▫️▫️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◽️◽️◽️◽️◽️▫️▫️▫️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◽️◽️◽️◽️◽️▫️▫️◽️◽️▫️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◽️◽️◽️◽️◽️▫️▫️◽️◽️▫️◽️◽️◽️◽️◽️◽️◻️
            ◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◻️◻️
            ◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◻️◻️◻️
            ◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◻️◻️
            ◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◻️◽️
            ◻️◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️
            ◻️◻️◻️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◽️◻️◻️◽️◽️◽️◽️
            """,
            .polygonpix: """
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️⬜️⬜️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            """,
            .rectanglepix: """
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️⬜️⬜️⬜️⬜️⬜️⬜️⬜️⬜️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            ◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️◾️
            """
        ]
        
        for shape in shapes {
        
            let pix = shape.key.pixType.init(at: .custom(w: 20, h: 20))
            
            let expect = XCTestExpectation()
            try! PixelKit.main.render.engine.manuallyRender {
                guard let pixels = pix.renderedPixels else {
                    XCTAssert(false);
                    expect.fulfill();
                    return
                }
                var text = ""
                for row in pixels.raw {
                    if text != "" {
                        text += "\n"
                    }
                    for pixel in row {
                        let c = pixel.color.lum.cg
                        text += c <= 0.0 ? "◾️" : c <= 0.25 ? "▫️" : c <= 0.5 ? "◽️" : c <= 0.75 ? "◻️" : "⬜️"
                    }
                }
                XCTAssertEqual(shape.value, text, "\(shape.key.name) has a bad map")
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
            
            pix.destroy()
            
        }
        
    }

    func testHueSaturationPix() {
        
        let colorPix = ColorPIX(at: ._128)
        colorPix.color = .red
        
        let hueSaturationPix = HueSaturationPIX()
        hueSaturationPix.input = colorPix
        hueSaturationPix.hue = 0.5
        hueSaturationPix.saturation = 0.5
                
        let expect = XCTestExpectation()
        try! PixelKit.main.render.engine.manuallyRender {
            guard let pixels = hueSaturationPix.renderedPixels else {
                XCTAssert(false);
                expect.fulfill();
                return
            }
            let color = pixels.average
            let hue = color.hue.cg
            let sat = color.sat.cg
            let roundHue = round(hue * 100) / 100
            let roundSat = round(sat * 100) / 100
            XCTAssertEqual(roundHue, 0.5)
            XCTAssertEqual(roundSat, 0.5)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
                
    }
    
    // MARK: - Cached Standard
    
    func testCachedGenerators() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("generators")
        
        for auto in AutoPIXGenerator.allCases {
                        
            let pix = auto.pixType.init(at: ._128)
            let bgPix = .black & pix
            
            let url = folderUrl.appendingPathComponent("\(auto.name).png")
            guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
            guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
            let imgPix = ImagePIX()
            imgPix.image = img
            
            let diffPix = bgPix % imgPix

            let expect = XCTestExpectation()
            try! PixelKit.main.render.engine.manuallyRender {
                
                guard let pixels = diffPix.renderedPixels else {
                    XCTAssert(false, auto.name);
                    expect.fulfill();
                    return
                }
                
                let avg = pixels.average.lum.cg
                XCTAssertEqual(avg, 0.0, auto.name)
//                if avg != 0.0 {
//                    let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_diff.png")
//                    guard let image: NSImage = diffPix.renderedImage else { fatalError() }
//                    guard image.savePNG(to: diffUrl) else { fatalError() }
//                }
                
                pix.destroy()
                imgPix.destroy()
                diffPix.destroy()
                
                expect.fulfill();
                
            }
            wait(for: [expect], timeout: 1.0)
            
        }
        
    }
        
    func testCachedSingleEffects() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("singleEffects")
        
        for auto in AutoPIXSingleEffect.allCases {
                        
            let pix = auto.pixType.init()
            pix.input = testPix
            let bgPix = .black & pix
            
            let url = folderUrl.appendingPathComponent("\(auto.name).png")
            guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
            guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
            let imgPix = ImagePIX()
            imgPix.image = img
            
            let diffPix = bgPix % imgPix

            let expect = XCTestExpectation()
            try! PixelKit.main.render.engine.manuallyRender {
                
                guard let pixels = diffPix.renderedPixels else {
                    XCTAssert(false, auto.name);
                    expect.fulfill();
                    return
                }
                
                let avg = pixels.average.lum.cg
                XCTAssertEqual(avg, 0.0, auto.name)
//                if avg != 0.0 {
//                    let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_diff.png")
//                    guard let diffImg: NSImage = diffPix.renderedImage else { fatalError() }
//                    guard diffImg.savePNG(to: diffUrl) else { fatalError() }
//                }
                
                pix.destroy()
                imgPix.destroy()
                diffPix.destroy()
                
                expect.fulfill();
                
            }
            wait(for: [expect], timeout: 1.0)
            
        }
        
    }
        
    func testCachedMergerEffects() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("mergerEffects")
        
        for auto in AutoPIXMergerEffect.allCases {
                        
            let pix = auto.pixType.init()
            pix.inputA = testPixA
            pix.inputB = testPixB
            let bgPix = .black & pix
            
            let url = folderUrl.appendingPathComponent("\(auto.name).png")
            guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
            guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
            let imgPix = ImagePIX()
            imgPix.image = img
            
            let diffPix = bgPix % imgPix

            let expect = XCTestExpectation()
            try! PixelKit.main.render.engine.manuallyRender {
                
                guard let pixels = diffPix.renderedPixels else {
                    XCTAssert(false, auto.name);
                    expect.fulfill();
                    return
                }
                
                let avg = pixels.average.lum.cg
                XCTAssertEqual(avg, 0.0, auto.name)
//                if avg != 0.0 {
//                    let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_diff.png")
//                    guard let diffImg: NSImage = diffPix.renderedImage else { fatalError() }
//                    guard diffImg.savePNG(to: diffUrl) else { fatalError() }
//                }
                
                pix.destroy()
                imgPix.destroy()
                diffPix.destroy()
                
                expect.fulfill();
                
            }
            wait(for: [expect], timeout: 1.0)
            
        }
        
    }
    
    // MARK: - Cached Random
        
    func testCachedRandomGenerators() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("randomGenerators")
        
        for auto in AutoPIXGenerator.allCases {
                        
            let pix = auto.pixType.init(at: ._128)
            let bgPix = .black & pix
            
            let imgPix = ImagePIX()
            
            let diffPix = bgPix % imgPix

            for i in 0..<Randomize.randomCount {
                
                let url = folderUrl.appendingPathComponent("\(auto.name)_\(i).png")
                guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
                guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
                imgPix.image = img
                
                Randomize.randomizeGenerator(auto: auto, with: pix, at: i)

                let expect = XCTestExpectation()
                try! PixelKit.main.render.engine.manuallyRender {
                    
                    guard let pixels = diffPix.renderedPixels else {
                        XCTAssert(false, auto.name);
                        expect.fulfill();
                        return
                    }
                    
                    let avg = pixels.average.lum.cg
                    XCTAssertEqual(avg, 0.0, auto.name)
//                    if avg != 0.0 {
//                        let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_\(i)_diff.png")
//                        guard let image: NSImage = diffPix.renderedImage else { fatalError() }
//                        guard image.savePNG(to: diffUrl) else { fatalError() }
//                    }
                    
                    expect.fulfill();
                    
                }
                wait(for: [expect], timeout: 1.0)
                
            }

            pix.destroy()
            imgPix.destroy()
            diffPix.destroy()
                        
        }
        
    }
            
    func testCachedRandomSingleEffects() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("randomSingleEffects")
        
        for auto in AutoPIXSingleEffect.allCases {
                        
            let pix = auto.pixType.init()
            pix.input = testPix
            let bgPix = .black & pix
            
            let imgPix = ImagePIX()
            
            let diffPix = bgPix % imgPix

            for i in 0..<Randomize.randomCount {
                
                let url = folderUrl.appendingPathComponent("\(auto.name)_\(i).png")
                guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
                guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
                imgPix.image = img
                
                Randomize.randomizeSingleEffect(auto: auto, with: pix, at: i)

                let expect = XCTestExpectation()
                try! PixelKit.main.render.engine.manuallyRender {
                    
                    guard let pixels = diffPix.renderedPixels else {
                        XCTAssert(false, auto.name);
                        expect.fulfill();
                        return
                    }
                    
                    let avg = pixels.average.lum.cg
                    XCTAssertEqual(avg, 0.0, auto.name)
//                    if avg != 0.0 {
//                        let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_\(i)_diff.png")
//                        guard let image: NSImage = diffPix.renderedImage else { fatalError() }
//                        guard image.savePNG(to: diffUrl) else { fatalError() }
//                    }
                    
                    expect.fulfill();
                    
                }
                wait(for: [expect], timeout: 1.0)
                
            }

            pix.destroy()
            imgPix.destroy()
            diffPix.destroy()
                        
        }
        
    }
                
    func testCachedRandomMergerEffects() {
        
        guard let outputUrl = Files.outputUrl() else { XCTAssert(false); return }
        let folderUrl = outputUrl.appendingPathComponent("randomMergerEffects")
        
        for auto in AutoPIXMergerEffect.allCases {
                        
            let pix = auto.pixType.init()
            pix.inputA = testPixA
            pix.inputB = testPixB
            let bgPix = .black & pix
            
            let imgPix = ImagePIX()
            
            let diffPix = bgPix % imgPix

            for i in 0..<Randomize.randomCount {
                
                let url = folderUrl.appendingPathComponent("\(auto.name)_\(i).png")
                guard let data = try? Data(contentsOf: url) else { XCTAssert(false, auto.name); continue }
                guard let img = NSImage(data: data) else { XCTAssert(false, auto.name); continue }
                imgPix.image = img
                
                Randomize.randomizeMergerEffect(auto: auto, with: pix, at: i)

                let expect = XCTestExpectation()
                try! PixelKit.main.render.engine.manuallyRender {
                    
                    guard let pixels = diffPix.renderedPixels else {
                        XCTAssert(false, auto.name);
                        expect.fulfill();
                        return
                    }
                    
                    let avg = pixels.average.lum.cg
                    XCTAssertEqual(avg, 0.0, auto.name)
//                    if avg != 0.0 {
//                        let diffUrl = folderUrl.appendingPathComponent("\(auto.name)_\(i)_diff.png")
//                        guard let image: NSImage = diffPix.renderedImage else { fatalError() }
//                        guard image.savePNG(to: diffUrl) else { fatalError() }
//                    }
                    
                    expect.fulfill();
                    
                }
                wait(for: [expect], timeout: 1.0)
                
            }

            pix.destroy()
            imgPix.destroy()
            diffPix.destroy()
                        
        }
        
    }

}

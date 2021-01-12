import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        
        print("PixelKit - Test - Set Up - Ready")
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        
    }
    
    func setUpManual() {
        PixelKit.main.render.engine.renderMode = .manual
    }
    
    func testMetalPixs() {
        _ = MetalPIX(code: "")
    }
    
//    func testAveragePixGenerators() {
//
//        setUpManual()
//
//        /// 8bit at 128x128
//        let averages: [AutoPIXGenerator: CGFloat] = [
//            .arcpix: 0.047119140625,
//            .circlepix: 0.197021484375,
//            .colorpix: 1.0,
//            .gradientpix: 0.5,
//            .linepix: 0.0115966796875,
//            .noisepix: 0.4070302925856992,
//            .polygonpix: 0.16357421875,
//            .rectanglepix: 0.19140625
//        ]
//
//        for average in averages {
//            print("testing", average.key.name)
//            let pix = average.key.pixType.init(at: ._128)
//
//            let expect = XCTestExpectation()
//            try! PixelKit.main.render.engine.manuallyRender {
//                guard let pixels = pix.renderedPixels else {
//                    XCTAssert(false);
//                    expect.fulfill();
//                    return
//                }
//                let lum = pixels.average.lum
//                XCTAssert(lum == average.value, "\(average.key.name) average should be \(average.value) and was \(lum)")
//                expect.fulfill()
//            }
//            self.wait(for: [expect], timeout: 1.0)
//
//            pix.destroy()
//
//        }
//
//    }
    
    static var allTests = [
        ("testMetalPixs", testMetalPixs),
//        ("testAveragePixGenerators", testAveragePixGenerators),
    ]
    
}

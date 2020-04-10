import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        
        #if os(macOS)
        let hexagonsURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib")
        if FileManager.default.fileExists(atPath: hexagonsURL.path) {
            print("PixelKit - Test - Set Up - Metal Lib - Hexagons")
            pixelKitMetalLibURL = hexagonsURL
        } else {
            print("PixelKit - Test - Set Up - Metal Lib - Online")
            let onlineURL: URL = URL(string: "https://github.com/hexagons/PixelKit/blob/master/Resources/Metal%20Libs/PixelKitShaders-macOS.metallib?raw=true")!
            let expectation = self.expectation(description: "Online Metal Lib")
            URLSession.shared.dataTask(with: onlineURL) { data, _, error in
                defer { expectation.fulfill() }
                guard error == nil else {
                    print("PixelKit - Test - Set Up - Metal Lib - Online - Failed with Error:", error!)
                    XCTFail("PixelKit-MetalLib-Online-FailError:\(String(describing: error))")
                    return
                }
                guard data != nil else {
                    print("PixelKit - Test - Set Up - Metal Lib - Online - Failed with no Data")
                    XCTFail("PixelKit-MetalLib-Online-FailData")
                    return
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let now: String = dateFormatter.string(from: Date())
                let tempURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PixelKitShaders-macOS--Test-Online--\(now).metallib")
                print("PixelKit - Test - Set Up - Metal Lib - Online - Temp Path:", tempURL.path)
                try! data!.write(to: tempURL)
                XCTAssert(FileManager.default.fileExists(atPath: tempURL.path))
                print("PixelKit - Test - Set Up - Metal Lib - Online - Done")
                pixelKitMetalLibURL = tempURL
            } .resume()
            waitForExpectations(timeout: 10, handler: nil)
        }
        #endif
        
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
    
    func testNames() {
        for pix in PIXAutoList.getAll() {
            XCTAssertNotNil(pix.name)
        }
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
//                let lum = pixels.average.lum.cg
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

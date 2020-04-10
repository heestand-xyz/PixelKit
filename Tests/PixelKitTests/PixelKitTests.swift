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
        
//        PixelKit.main.render.engine.renderMode = .manual
    }
    
    func testMetalPixs() {
        _ = MetalPIX(code: "")
    }
    
    func testNames() {
        for pix in PIXAutoList.getAll() {
            XCTAssertNotNil(pix.name)
        }
    }

    static var allTests = [
        ("testMetalPixs", testMetalPixs),
    ]
    
}

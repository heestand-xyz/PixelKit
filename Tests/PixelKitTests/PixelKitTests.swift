import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib")
//        PixelKit.main.render.engine.renderMode = .manual
    }
    
    func testMetalPixs() {
        _ = MetalPIX(code: "")
    }

    static var allTests = [
        ("testMetalPixs", testMetalPixs),
    ]
    
}

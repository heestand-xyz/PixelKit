import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        #if os(macOS)
        pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib")
        #endif
//        PixelKit.main.render.engine.renderMode = .manual
    }
    
    func testMetalPixs() {
        _ = MetalPIX(code: "")
    }

    static var allTests = [
        ("testMetalPixs", testMetalPixs),
    ]
    
}

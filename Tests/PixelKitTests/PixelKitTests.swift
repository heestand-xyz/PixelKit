import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        PixelKit.main.render.engine.renderMode = .manual
    }
    
    func testPix() {
        
    }

    static var allTests = [
        ("testPix", testPix),
    ]
    
}

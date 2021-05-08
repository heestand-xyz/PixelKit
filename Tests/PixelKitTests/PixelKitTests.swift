import XCTest
@testable import PixelKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        
    }
    
    func testCodable() {
        
        let circlePix = CirclePIX(at: ._512)
        circlePix.radius = 0.2
        circlePix.edgeRadius = 0.05
        circlePix.color = .blue
        circlePix.position = CGPoint(x: 0.25, y: 0.25)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data: Data = try! encoder.encode(circlePix)
        
        let json: String = String(data: data, encoding: .utf8)!
        print(json)
        
        let decoder = JSONDecoder()
        let decodedPix: CirclePIX = try! decoder.decode(CirclePIX.self, from: data)
        
        XCTAssertEqual(decodedPix.radius, 0.2)
        XCTAssertEqual(decodedPix.edgeRadius, 0.05)
        XCTAssertEqual(decodedPix.color, .blue)
        XCTAssertEqual(decodedPix.position, CGPoint(x: 0.25, y: 0.25))
    }
    
    static var allTests = [
        ("testCodable", testCodable),
    ]
    
}

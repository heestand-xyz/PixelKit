import XCTest
@testable import PixelKit
import RenderKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        
    }
    
    func testReference() {
        
        var pixs: [WeakNODE] = []
        for pixType in PIXGeneratorType.allCases {
            if pixType == .metal { continue }
            let pix: PIX = pixType.type.init(at: ._128)
            pixs.append(WeakNODE(pix))
        }
        for pixType in PIXResourceType.allCases {
            if pixType == .camera { continue }
            #if os(macOS)
            if pixType == .screenCapture { continue }
            #endif
            guard let pix: PIX = pixType.type?.init() else { continue }
            pixs.append(WeakNODE(pix))
        }
        for pixType in PIXSingleEffectType.allCases {
            if pixType == .metalEffect { continue }
            let pix: PIX = pixType.type.init()
            pixs.append(WeakNODE(pix))
        }
        for pixType in PIXMergerEffectType.allCases {
            if pixType == .metalMergerEffect { continue }
            let pix: PIX = pixType.type.init()
            pixs.append(WeakNODE(pix))
        }
        for pixType in PIXMultiEffectType.allCases {
            if pixType == .metalMultiEffect { continue }
            let pix: PIX = pixType.type.init()
            pixs.append(WeakNODE(pix))
        }
        for pixType in PIXOutputType.allCases {
            guard let pix: PIX = pixType.type?.init() else { continue }
            pixs.append(WeakNODE(pix))
        }
        
        pixs.forEach { weakNode in
            let pix: PIX? = weakNode.node as? PIX
            XCTAssertEqual(pix, nil)
        }
        
    }
    
    func testCodable() {
        
        let circlePix = CirclePIX(at: ._512)
        circlePix.radius = 0.2
        circlePix.edgeRadius = 0.05
        circlePix.color = .rawBlue
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
        XCTAssertEqual(decodedPix.color, .rawBlue)
        XCTAssertEqual(decodedPix.position, CGPoint(x: 0.25, y: 0.25))
    }
    
    static var allTests = [
        ("testReference", testReference),
        ("testCodable", testCodable),
    ]
    
}

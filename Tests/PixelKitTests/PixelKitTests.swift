import XCTest
@testable import PixelKit
import RenderKit

final class PixelKitTests: XCTestCase {
    
    override func setUp() {
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        
    }
    
    func testLegacyCodable() throws {
        
        guard let url = Bundle.module.url(forResource: "pix-content-generator-arc", withExtension: "json") else { fatalError() }
        XCTAssert(FileManager.default.fileExists(atPath: url.path))
        
        let data = try Data(contentsOf: url)
        
        _ = try JSONDecoder().decode(ArcPixelModel.self, from: data)
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
            guard let pix: PIX = pixType.type?.init() else { continue }
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
    
    static var allTests = [
        ("testReference", testReference),
        ("testLegacyCodable", testLegacyCodable),
    ]
    
}

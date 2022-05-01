//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public struct MetalPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal"
    public var typeName: String = "pix-content-generator-metal"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var premultiply: Bool = true
    public var resolution: Resolution = .auto

    public var backgroundColor: PixelColor = .black
    public var color: PixelColor = .white
    
    // MARK: Local
    
    public var metalUniforms: [MetalUniform] = []
    public var code: String = "return float4(u, v, 0.0, 1.0);"
}

extension MetalPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case metalUniforms
        case code
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        code = try container.decode(String.self, forKey: .code)
    }
}

extension MetalPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelGeneratorEqual(to: pixelModel) else { return false }
        guard metalUniforms == pixelModel.metalUniforms else { return false }
        guard code == pixelModel.code else { return false }
        return true
    }
}

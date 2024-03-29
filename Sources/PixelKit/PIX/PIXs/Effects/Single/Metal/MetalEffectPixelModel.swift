//
//  Created by Anton Heestand on 2022-01-06.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MetalEffectPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal (1FX)"
    public var typeName: String = "pix-effect-single-metal"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var metalUniforms: [MetalUniform] = []
    public var code: String = "return pix;"
}

extension MetalEffectPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case metalUniforms
        case code
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        code = try container.decode(String.self, forKey: .code)
    }
}

extension MetalEffectPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard metalUniforms == pixelModel.metalUniforms else { return false }
        guard code == pixelModel.code else { return false }
        return true
    }
}

//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MetalMergerEffectPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal (2FX)"
    public var typeName: String = "pix-effect-merger-metal"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var metalUniforms: [MetalUniform] = []
    public var code: String = "return pixA + pixB;"
}

extension MetalMergerEffectPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case metalUniforms
        case code
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        code = try container.decode(String.self, forKey: .code)
    }
}

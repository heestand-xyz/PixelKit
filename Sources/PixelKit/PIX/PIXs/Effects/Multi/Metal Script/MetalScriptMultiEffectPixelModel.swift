//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MetalScriptMultiEffectPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal Script (NFX)"
    public var typeName: String = "pix-effect-multi-metal-script"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var colorStyle: MetalScriptMultiEffectPIX.ColorStyle = .color
    public var metalUniforms: [MetalUniform] = []
    public var whiteScript: String = "texs.sample(s, uv, 0).r"
    public var redScript: String = "texs.sample(s, uv, 0).r"
    public var greenScript: String = "texs.sample(s, uv, 0).g"
    public var blueScript: String = "texs.sample(s, uv, 0).b"
    public var alphaScript: String = "texs.sample(s, uv, 0).a"
}

extension MetalScriptMultiEffectPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case colorStyle
        case metalUniforms
        case whiteScript
        case redScript
        case greenScript
        case blueScript
        case alphaScript
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMultiEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        whiteScript = try container.decode(String.self, forKey: .whiteScript)
        redScript = try container.decode(String.self, forKey: .redScript)
        greenScript = try container.decode(String.self, forKey: .greenScript)
        blueScript = try container.decode(String.self, forKey: .blueScript)
        alphaScript = try container.decode(String.self, forKey: .alphaScript)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .colorStyle:
                    let live: LiveEnum<MetalScriptMultiEffectPIX.ColorStyle> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    colorStyle = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        colorStyle = try container.decode(MetalScriptMultiEffectPIX.ColorStyle.self, forKey: .colorStyle)
    }
}

extension MetalScriptMultiEffectPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMultiEffectEqual(to: pixelModel) else { return false }
        guard colorStyle == pixelModel.colorStyle else { return false }
        guard metalUniforms == pixelModel.metalUniforms else { return false }
        guard whiteScript == pixelModel.whiteScript else { return false }
        guard redScript == pixelModel.redScript else { return false }
        guard greenScript == pixelModel.greenScript else { return false }
        guard blueScript == pixelModel.blueScript else { return false }
        guard alphaScript == pixelModel.alphaScript else { return false }
        return true
    }
}

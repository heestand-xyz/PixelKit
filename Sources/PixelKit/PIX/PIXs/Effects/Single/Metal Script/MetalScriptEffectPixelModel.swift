//
//  Created by Anton Heestand on 2022-01-06.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MetalScriptEffectPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal Script (1FX)"
    public var typeName: String = "pix-effect-single-metal-script"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var colorStyle: MetalScriptEffectPIX.ColorStyle = .color
    public var metalUniforms: [MetalUniform] = []
    public var whiteScript: String = "white"
    public var redScript: String = "red"
    public var greenScript: String = "green"
    public var blueScript: String = "blue"
    public var alphaScript: String = "alpha"
}

extension MetalScriptEffectPixelModel {
    
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
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self

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
                    let live: LiveEnum<MetalScriptEffectPIX.ColorStyle> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    colorStyle = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        colorStyle = try container.decode(MetalScriptEffectPIX.ColorStyle.self, forKey: .colorStyle)
    }
}

extension MetalScriptEffectPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
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

//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MetalScriptMergerEffectPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Metal Script (2FX)"
    public var typeName: String = "pix-effect-merger-metal-script"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var colorStyle: MetalScriptMergerEffectPIX.ColorStyle = .color
    public var metalUniforms: [MetalUniform] = []
    public var whiteScript: String = "whiteA + whiteB"
    public var redScript: String = "redA + redB"
    public var greenScript: String = "greenA + greenB"
    public var blueScript: String = "blueA + blueB"
    public var alphaScript: String = "alphaA + alphaB"
}

extension MetalScriptMergerEffectPixelModel {
    
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
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
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
                    guard let live = liveWrap as? LiveEnum<MetalScriptMergerEffectPIX.ColorStyle> else { continue }
                    colorStyle = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        colorStyle = try container.decode(MetalScriptMergerEffectPIX.ColorStyle.self, forKey: .colorStyle)
    }
}

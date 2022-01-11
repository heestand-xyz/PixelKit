//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public struct MetalScriptPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "MetalScript"
    public var typeName: String = "pix-content-generator-metal-script"
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
    
    public var colorStyle: MetalScriptPIX.ColorStyle = .color
    public var metalUniforms: [MetalUniform] = []
    public var whiteScript: String = "1.0"
    public var redScript: String = "v"
    public var greenScript: String = "v"
    public var blueScript: String = "1.0"
    public var alphaScript: String = "1.0"
}

extension MetalScriptPixelModel {
    
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
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self

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
                    guard let live = liveWrap as? LiveEnum<MetalScriptPIX.ColorStyle> else { continue }
                    colorStyle = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        colorStyle = try container.decode(MetalScriptPIX.ColorStyle.self, forKey: .colorStyle)
    }
}


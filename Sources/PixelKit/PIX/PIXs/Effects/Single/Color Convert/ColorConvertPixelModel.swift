//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ColorConvertPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Color Convert"
    public var typeName: String = "pix-effect-single-color-convert"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var conversion: ColorConvertPIX.Conversion = .rgbToHsv
    public var channel: ColorConvertPIX.Channel = .all
    
}

extension ColorConvertPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case conversion
        case channel
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .conversion:
                    guard let live = liveWrap as? LiveEnum<ColorConvertPIX.Conversion> else { continue }
                    conversion = live.wrappedValue
                case .channel:
                    guard let live = liveWrap as? LiveEnum<ColorConvertPIX.Channel> else { continue }
                    channel = live.wrappedValue
                }
            }
            return
        }
        
        conversion = try container.decode(ColorConvertPIX.Conversion.self, forKey: .conversion)
        channel = try container.decode(ColorConvertPIX.Channel.self, forKey: .channel)
    }
}

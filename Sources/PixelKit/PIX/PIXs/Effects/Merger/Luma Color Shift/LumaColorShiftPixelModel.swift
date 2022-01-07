//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LumaColorShiftPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Luma Color Shift"
    public var typeName: String = "pix-effect-merger-luma-color-shift"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 1.0
    public var tintColor: PixelColor = .white
    public var lumaGamma: CGFloat = 1.0
}

extension LumaColorShiftPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case hue
        case saturation
        case tintColor
        case lumaGamma
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .hue:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    hue = live.wrappedValue
                case .saturation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    saturation = live.wrappedValue
                case .tintColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    tintColor = live.wrappedValue
                case .lumaGamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    lumaGamma = live.wrappedValue
                }
            }
            return
        }
        
        hue = try container.decode(CGFloat.self, forKey: .hue)
        saturation = try container.decode(CGFloat.self, forKey: .saturation)
        tintColor = try container.decode(PixelColor.self, forKey: .tintColor)
        lumaGamma = try container.decode(CGFloat.self, forKey: .lumaGamma)
    }
}

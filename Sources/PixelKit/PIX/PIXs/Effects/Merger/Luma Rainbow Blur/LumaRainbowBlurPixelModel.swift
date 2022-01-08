//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LumaRainbowBlurPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Luma Rainbow Blur"
    public var typeName: String = "pix-effect-merger-luma-rainbow-blur"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .hold
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var style: LumaRainbowBlurPIX.Style = .zoom
    public var radius: CGFloat = 0.5
    public var quality: PIX.SampleQualityMode = .default
    public var angle: CGFloat = 0.0
    public var position: CGPoint = .zero
    public var light: CGFloat = 1.0
    public var lumaGamma: CGFloat = 1.0
}

extension LumaRainbowBlurPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case style
        case radius
        case quality
        case angle
        case position
        case light
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
                case .style:
                    guard let live = liveWrap as? LiveEnum<LumaRainbowBlurPIX.Style> else { continue }
                    style = live.wrappedValue
                case .radius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    radius = live.wrappedValue
                case .quality:
                    guard let live = liveWrap as? LiveEnum<PIX.SampleQualityMode> else { continue }
                    quality = live.wrappedValue
                case .angle:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    angle = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .light:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    light = live.wrappedValue
                case .lumaGamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    lumaGamma = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(LumaRainbowBlurPIX.Style.self, forKey: .style)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        quality = try container.decode(PIX.SampleQualityMode.self, forKey: .quality)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        position = try container.decode(CGPoint.self, forKey: .position)
        light = try container.decode(CGFloat.self, forKey: .light)
        lumaGamma = try container.decode(CGFloat.self, forKey: .lumaGamma)
    }
}

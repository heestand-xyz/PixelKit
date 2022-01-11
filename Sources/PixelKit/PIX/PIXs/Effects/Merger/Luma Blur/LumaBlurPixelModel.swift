//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LumaBlurPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Luma Blur"
    public var typeName: String = "pix-effect-merger-luma-blur"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .hold
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var style: LumaBlurPIX.Style = .box
    public var radius: CGFloat = 0.5
    public var quality: PIX.SampleQualityMode = .default
    public var angle: CGFloat = 0.0
    public var position: CGPoint = .zero
    public var lumaGamma: CGFloat = 1.0
}

extension LumaBlurPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case style
        case radius
        case quality
        case angle
        case position
        case lumaGamma
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .style:
                    guard let live = liveWrap as? LiveEnum<LumaBlurPIX.Style> else { continue }
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
                case .lumaGamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    lumaGamma = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(LumaBlurPIX.Style.self, forKey: .style)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        quality = try container.decode(PIX.SampleQualityMode.self, forKey: .quality)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        position = try container.decode(CGPoint.self, forKey: .position)
        lumaGamma = try container.decode(CGFloat.self, forKey: .lumaGamma)
    }
}

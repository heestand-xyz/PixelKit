//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct WarpPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Warp"
    public var typeName: String = "pix-effect-single-warp"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var style: WarpPIX.Style = .hole
    public var position: CGPoint = .zero
    public var radius: CGFloat = 0.125
    public var scale: CGFloat = 0.5
    public var rotation: CGFloat = 0.0
}

extension WarpPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case style
        case position
        case radius
        case scale
        case rotation
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .style:
                    let live: LiveEnum<WarpPIX.Style> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    style = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .radius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    radius = live.wrappedValue
                case .scale:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    scale = live.wrappedValue
                case .rotation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    rotation = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(WarpPIX.Style.self, forKey: .style)
        position = try container.decode(CGPoint.self, forKey: .position)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
    }
}

extension WarpPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard style == pixelModel.style else { return false }
        guard position == pixelModel.position else { return false }
        guard radius == pixelModel.radius else { return false }
        guard scale == pixelModel.scale else { return false }
        guard rotation == pixelModel.rotation else { return false }
        return true
    }
}

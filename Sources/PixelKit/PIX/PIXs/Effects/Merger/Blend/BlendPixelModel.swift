//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct BlendPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Blend"
    public var typeName: String = "pix-effect-merger-blend"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var blendMode: BlendMode = .add
    public var bypassTransform: Bool = false
    public var position: CGPoint = .zero
    public var rotation: CGFloat = 0.0
    public var scale: CGFloat = 1.0
    public var size: CGSize = CGSize(width: 1.0, height: 1.0)
}

extension BlendPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case blendMode
        case bypassTransform
        case position
        case rotation
        case scale
        case size
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .blendMode:
                    let live: LiveEnum<BlendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    blendMode = live.wrappedValue
                case .bypassTransform:
                    guard let live = liveWrap as? LiveBool else { continue }
                    bypassTransform = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .rotation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    rotation = live.wrappedValue
                case .scale:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    scale = live.wrappedValue
                case .size:
                    guard let live = liveWrap as? LiveSize else { continue }
                    size = live.wrappedValue
                }
            }
            return
        }
        
        blendMode = try container.decode(BlendMode.self, forKey: .blendMode)
        bypassTransform = try container.decode(Bool.self, forKey: .bypassTransform)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        size = try container.decode(CGSize.self, forKey: .size)
    }
}

extension BlendPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMergerEffectEqual(to: pixelModel) else { return false }
        guard blendMode == pixelModel.blendMode else { return false }
        guard bypassTransform == pixelModel.bypassTransform else { return false }
        guard position == pixelModel.position else { return false }
        guard rotation == pixelModel.rotation else { return false }
        guard scale == pixelModel.scale else { return false }
        guard size == pixelModel.size else { return false }
        return true
    }
}

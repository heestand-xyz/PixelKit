//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct GradientPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Gradient"
    public var typeName: String = "pix-content-generator-gradient"
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
    
    public var colorStops: [ColorStop] = [ColorStop(0.0, .black), ColorStop(1.0, .white)]
    public var direction: GradientPIX.Direction = .vertical
    public var scale: CGFloat = 1.0
    public var offset: CGFloat = 0.0
    public var position: CGPoint = .zero
    public var gamma: CGFloat = 1.0
    public var extendMode: ExtendMode = .hold
}

extension GradientPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case colorStops
        case direction
        case scale
        case offset
        case position
        case gamma
        case extendMode
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        colorStops = try container.decode([ColorStop].self, forKey: .colorStops)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .colorStops:
                    continue
                case .direction:
                    let live: LiveEnum<GradientPIX.Direction> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    direction = live.wrappedValue
                case .scale:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    scale = live.wrappedValue
                case .offset:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    offset = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .gamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    gamma = live.wrappedValue
                case .extendMode:
                    let live: LiveEnum<ExtendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    extendMode = live.wrappedValue
                }
            }
            return
        }
        
        direction = try container.decode(GradientPIX.Direction.self, forKey: .direction)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        offset = try container.decode(CGFloat.self, forKey: .offset)
        position = try container.decode(CGPoint.self, forKey: .position)
        gamma = try container.decode(CGFloat.self, forKey: .gamma)
        extendMode = try container.decode(ExtendMode.self, forKey: .extendMode)
    }
}

extension GradientPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelGeneratorEqual(to: pixelModel) else { return false }
        guard colorStops == pixelModel.colorStops else { return false }
        guard direction == pixelModel.direction else { return false }
        guard scale == pixelModel.scale else { return false }
        guard offset == pixelModel.offset else { return false }
        guard position == pixelModel.position else { return false }
        guard gamma == pixelModel.gamma else { return false }
        guard extendMode == pixelModel.extendMode else { return false }
        return true
    }
}

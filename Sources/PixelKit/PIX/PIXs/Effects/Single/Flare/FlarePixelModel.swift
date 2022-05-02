//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct FlarePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Flare"
    public var typeName: String = "pix-effect-single-flare"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var scale: CGFloat = 0.25
    public var count: Int = 6
    public var angle: CGFloat = 0.25
    public var threshold: CGFloat = 0.95
    public var brightness: CGFloat = 1.0
    public var gamma: CGFloat = 0.25
    public var color: PixelColor = PixelColor(red: 1.0, green: 0.5, blue: 0.0)
    public var rayResolution: Int = 32
}

extension FlarePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case scale
        case count
        case angle
        case threshold
        case brightness
        case gamma
        case color
        case rayResolution
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .scale:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    scale = live.wrappedValue
                case .count:
                    guard let live = liveWrap as? LiveInt else { continue }
                    count = live.wrappedValue
                case .angle:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    angle = live.wrappedValue
                case .threshold:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    threshold = live.wrappedValue
                case .brightness:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    brightness = live.wrappedValue
                case .gamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    gamma = live.wrappedValue
                case .color:
                    guard let live = liveWrap as? LiveColor else { continue }
                    color = live.wrappedValue
                case .rayResolution:
                    guard let live = liveWrap as? LiveInt else { continue }
                    rayResolution = live.wrappedValue
                }
            }
            return
        }
        
        scale = try container.decode(CGFloat.self, forKey: .scale)
        count = try container.decode(Int.self, forKey: .count)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
        brightness = try container.decode(CGFloat.self, forKey: .brightness)
        gamma = try container.decode(CGFloat.self, forKey: .gamma)
        color = try container.decode(PixelColor.self, forKey: .color)
        rayResolution = try container.decode(Int.self, forKey: .rayResolution)
    }
}

extension FlarePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard scale == pixelModel.scale else { return false }
        guard count == pixelModel.count else { return false }
        guard angle == pixelModel.angle else { return false }
        guard threshold == pixelModel.threshold else { return false }
        guard brightness == pixelModel.brightness else { return false }
        guard gamma == pixelModel.gamma else { return false }
        guard color == pixelModel.color else { return false }
        guard rayResolution == pixelModel.rayResolution else { return false }
        return true
    }
}

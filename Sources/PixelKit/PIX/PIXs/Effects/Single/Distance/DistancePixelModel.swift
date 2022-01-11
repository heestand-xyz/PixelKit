//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct DistancePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Distance"
    public var typeName: String = "pix-effect-single-distance"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var count: Int = 32
    public var distance: CGFloat = 0.02
    public var threshold: CGFloat = 0.0
    public var brightness: CGFloat = 0.5
}

extension DistancePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case count
        case distance
        case threshold
        case brightness
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .count:
                    guard let live = liveWrap as? LiveInt else { continue }
                    count = live.wrappedValue
                case .distance:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    distance = live.wrappedValue
                case .threshold:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    threshold = live.wrappedValue
                case .brightness:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    brightness = live.wrappedValue
                }
            }
            return
        }
        
        count = try container.decode(Int.self, forKey: .count)
        distance = try container.decode(CGFloat.self, forKey: .distance)
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
        brightness = try container.decode(CGFloat.self, forKey: .brightness)
    }
}

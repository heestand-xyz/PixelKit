//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LevelsPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Levels"
    public var typeName: String = "pix-effect-single-levels"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var brightness: CGFloat = 1.0
    public var darkness: CGFloat = 0.0
    public var contrast: CGFloat = 0.0
    public var gamma: CGFloat = 1.0
    public var inverted: Bool = false
    public var smooth: Bool = false
    public var opacity: CGFloat = 1.0
    public var offset: CGFloat = 0.0
}

extension LevelsPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case brightness
        case darkness
        case contrast
        case gamma
        case inverted
        case smooth
        case opacity
        case offset
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .brightness:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    brightness = live.wrappedValue
                case .darkness:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    darkness = live.wrappedValue
                case .contrast:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    contrast = live.wrappedValue
                case .gamma:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    gamma = live.wrappedValue
                case .inverted:
                    guard let live = liveWrap as? LiveBool else { continue }
                    inverted = live.wrappedValue
                case .smooth:
                    guard let live = liveWrap as? LiveBool else { continue }
                    smooth = live.wrappedValue
                case .opacity:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    opacity = live.wrappedValue
                case .offset:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    offset = live.wrappedValue
                }
            }
            return
        }
        
        brightness = try container.decode(CGFloat.self, forKey: .brightness)
        darkness = try container.decode(CGFloat.self, forKey: .darkness)
        contrast = try container.decode(CGFloat.self, forKey: .contrast)
        gamma = try container.decode(CGFloat.self, forKey: .gamma)
        inverted = try container.decode(Bool.self, forKey: .inverted)
        smooth = try container.decode(Bool.self, forKey: .smooth)
        opacity = try container.decode(CGFloat.self, forKey: .opacity)
        offset = try container.decode(CGFloat.self, forKey: .offset)
    }
}

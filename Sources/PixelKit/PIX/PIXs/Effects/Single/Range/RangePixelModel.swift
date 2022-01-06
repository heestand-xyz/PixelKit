//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct RangePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Range"
    public var typeName: String = "pix-effect-single-range"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var inLow: CGFloat = 0.0
    public var inHigh: CGFloat = 1.0
    public var outLow: CGFloat = 0.0
    public var outHigh: CGFloat = 1.0
    public var inLowColor: PixelColor = .clear
    public var inHighColor: PixelColor = .white
    public var outLowColor: PixelColor = .clear
    public var outHighColor: PixelColor = .white
    public var ignoreAlpha: Bool = true
}

extension RangePixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case inLow
        case inHigh
        case outLow
        case outHigh
        case inLowColor
        case inHighColor
        case outLowColor
        case outHighColor
        case ignoreAlpha
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .inLow:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    inLow = live.wrappedValue
                case .inHigh:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    inHigh = live.wrappedValue
                case .outLow:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    outLow = live.wrappedValue
                case .outHigh:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    outHigh = live.wrappedValue
                case .inLowColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    inLowColor = live.wrappedValue
                case .inHighColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    inHighColor = live.wrappedValue
                case .outLowColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    outLowColor = live.wrappedValue
                case .outHighColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    outHighColor = live.wrappedValue
                case .ignoreAlpha:
                    guard let live = liveWrap as? LiveBool else { continue }
                    ignoreAlpha = live.wrappedValue
                }
            }
            return
        }
        
        inLow = try container.decode(CGFloat.self, forKey: .inLow)
        inHigh = try container.decode(CGFloat.self, forKey: .inHigh)
        outLow = try container.decode(CGFloat.self, forKey: .outLow)
        outHigh = try container.decode(CGFloat.self, forKey: .outHigh)
        inLowColor = try container.decode(PixelColor.self, forKey: .inLowColor)
        inHighColor = try container.decode(PixelColor.self, forKey: .inHighColor)
        outLowColor = try container.decode(PixelColor.self, forKey: .outLowColor)
        outHighColor = try container.decode(PixelColor.self, forKey: .outHighColor)
        ignoreAlpha = try container.decode(Bool.self, forKey: .ignoreAlpha)
    }
}

//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ChannelMixPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Channel Mix"
    public var typeName: String = "pix-effect-single-channel-mix"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var red: ChannelMixPIX.Channel = .red
    public var green: ChannelMixPIX.Channel = .green
    public var blue: ChannelMixPIX.Channel = .blue
    public var alpha: ChannelMixPIX.Channel = .alpha
}

extension ChannelMixPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case red
        case green
        case blue
        case alpha
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .red:
                    guard let live = liveWrap as? LiveEnum<ChannelMixPIX.Channel> else { continue }
                    red = live.wrappedValue
                case .green:
                    guard let live = liveWrap as? LiveEnum<ChannelMixPIX.Channel> else { continue }
                    green = live.wrappedValue
                case .blue:
                    guard let live = liveWrap as? LiveEnum<ChannelMixPIX.Channel> else { continue }
                    blue = live.wrappedValue
                case .alpha:
                    guard let live = liveWrap as? LiveEnum<ChannelMixPIX.Channel> else { continue }
                    alpha = live.wrappedValue
                }
            }
            return
        }
        
        red = try container.decode(ChannelMixPIX.Channel.self, forKey: .red)
        green = try container.decode(ChannelMixPIX.Channel.self, forKey: .green)
        blue = try container.decode(ChannelMixPIX.Channel.self, forKey: .blue)
        alpha = try container.decode(ChannelMixPIX.Channel.self, forKey: .alpha)
    }
}

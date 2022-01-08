//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ReorderPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Reorder"
    public var typeName: String = "pix-effect-merger-reorder"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var redInput: ReorderPIX.Input = .first
    public var greenInput: ReorderPIX.Input = .first
    public var blueInput: ReorderPIX.Input = .first
    public var alphaInput: ReorderPIX.Input = .first
    public var redChannel: ReorderPIX.Channel = .red
    public var greenChannel: ReorderPIX.Channel = .green
    public var blueChannel: ReorderPIX.Channel = .blue
    public var alphaChannel: ReorderPIX.Channel = .alpha
    public var premultiply: Bool = true
}

extension ReorderPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case redInput
        case greenInput
        case blueInput
        case alphaInput
        case redChannel
        case greenChannel
        case blueChannel
        case alphaChannel
        case premultiply
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .redInput:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Input> else { continue }
                    redInput = live.wrappedValue
                case .greenInput:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Input> else { continue }
                    greenInput = live.wrappedValue
                case .blueInput:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Input> else { continue }
                    blueInput = live.wrappedValue
                case .alphaInput:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Input> else { continue }
                    alphaInput = live.wrappedValue
                case .redChannel:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Channel> else { continue }
                    redChannel = live.wrappedValue
                case .greenChannel:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Channel> else { continue }
                    greenChannel = live.wrappedValue
                case .blueChannel:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Channel> else { continue }
                    blueChannel = live.wrappedValue
                case .alphaChannel:
                    guard let live = liveWrap as? LiveEnum<ReorderPIX.Channel> else { continue }
                    alphaChannel = live.wrappedValue
                case .premultiply:
                    guard let live = liveWrap as? LiveBool else { continue }
                    premultiply = live.wrappedValue
                }
            }
            return
        }
        
        redInput = try container.decode(ReorderPIX.Input.self, forKey: .redInput)
        greenInput = try container.decode(ReorderPIX.Input.self, forKey: .greenInput)
        blueInput = try container.decode(ReorderPIX.Input.self, forKey: .blueInput)
        alphaInput = try container.decode(ReorderPIX.Input.self, forKey: .alphaInput)
        redChannel = try container.decode(ReorderPIX.Channel.self, forKey: .redChannel)
        greenChannel = try container.decode(ReorderPIX.Channel.self, forKey: .greenChannel)
        blueChannel = try container.decode(ReorderPIX.Channel.self, forKey: .blueChannel)
        alphaChannel = try container.decode(ReorderPIX.Channel.self, forKey: .alphaChannel)
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
    }
}

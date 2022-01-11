//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct FlipFlopPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Flip Flop"
    public var typeName: String = "pix-effect-single-flip-flop"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var flip: FlipFlopPIX.Flip = .none
    public var flop: FlipFlopPIX.Flop = .none
}

extension FlipFlopPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case flip
        case flop
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .flip:
                    guard let live = liveWrap as? LiveEnum<FlipFlopPIX.Flip> else { continue }
                    flip = live.wrappedValue
                case .flop:
                    guard let live = liveWrap as? LiveEnum<FlipFlopPIX.Flop> else { continue }
                    flop = live.wrappedValue
                }
            }
            return
        }
        
        flip = try container.decode(FlipFlopPIX.Flip.self, forKey: .flip)
        flop = try container.decode(FlipFlopPIX.Flop.self, forKey: .flop)
    }
}

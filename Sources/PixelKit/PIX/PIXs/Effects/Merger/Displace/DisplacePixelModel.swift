//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct DisplacePixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Displace"
    public var typeName: String = "pix-effect-merger-displace"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .hold
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var distance: CGFloat = 0.25
    public var origin: CGFloat = 0.5
}

extension DisplacePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case distance
        case origin
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .distance:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    distance = live.wrappedValue
                case .origin:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    origin = live.wrappedValue
                }
            }
            return
        }
        
        distance = try container.decode(CGFloat.self, forKey: .distance)
        origin = try container.decode(CGFloat.self, forKey: .origin)
    }
}

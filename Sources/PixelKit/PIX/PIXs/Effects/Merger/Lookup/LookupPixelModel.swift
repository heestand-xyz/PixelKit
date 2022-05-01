//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LookupPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Lookup"
    public var typeName: String = "pix-effect-merger-lookup"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .hold
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var axis: LookupPIX.Axis = .vertical
    public var holdEdge: Bool = true
}

extension LookupPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case axis
        case holdEdge
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .axis:
                    let live: LiveEnum<LookupPIX.Axis> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    axis = live.wrappedValue
                case .holdEdge:
                    guard let live = liveWrap as? LiveBool else { continue }
                    holdEdge = live.wrappedValue
                }
            }
            return
        }
        
        axis = try container.decode(LookupPIX.Axis.self, forKey: .axis)
        holdEdge = try container.decode(Bool.self, forKey: .holdEdge)
    }
}

extension LookupPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMergerEffectEqual(to: pixelModel) else { return false }
        guard axis == pixelModel.axis else { return false }
        guard holdEdge == pixelModel.holdEdge else { return false }
        return true
    }
}

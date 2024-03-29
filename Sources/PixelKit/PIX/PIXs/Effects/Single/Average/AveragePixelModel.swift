//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct AveragePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Average"
    public var typeName: String = "pix-effect-single-average"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var axis: AveragePIX.Axis = .z
}

extension AveragePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case axis
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .axis:
                    let live: LiveEnum<AveragePIX.Axis> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    axis = live.wrappedValue
                }
            }
            return
        }
        
        axis = try container.decode(AveragePIX.Axis.self, forKey: .axis)
    }
}

extension AveragePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard axis == pixelModel.axis else { return false }
        return true
    }
}

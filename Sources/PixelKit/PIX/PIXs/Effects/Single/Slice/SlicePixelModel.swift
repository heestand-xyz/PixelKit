//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct SlicePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Slice"
    public var typeName: String = "pix-effect-single-slice"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var fraction: CGFloat = 0.5
    public var axis: SlicePIX.Axis = .z
}

extension SlicePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case fraction
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
                case .fraction:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    fraction = live.wrappedValue
                case .axis:
                    let live: LiveEnum<SlicePIX.Axis> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    axis = live.wrappedValue
                }
            }
            return
        }
        
        fraction = try container.decode(CGFloat.self, forKey: .fraction)
        axis = try container.decode(SlicePIX.Axis.self, forKey: .axis)
    }
}

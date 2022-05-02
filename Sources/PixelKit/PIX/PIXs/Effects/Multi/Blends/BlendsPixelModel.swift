//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct BlendsPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Blends"
    public var typeName: String = "pix-effect-multi-blends"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var blendMode: BlendMode = .add
}

extension BlendsPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case blendMode
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMultiEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
                
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .blendMode:
                    let live: LiveEnum<BlendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    blendMode = live.wrappedValue
                }
            }
            return
        }
        
        blendMode = try container.decode(BlendMode.self, forKey: .blendMode)
    }
}

extension BlendsPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMultiEffectEqual(to: pixelModel) else { return false }
        guard blendMode == pixelModel.blendMode else { return false }
        return true
    }
}

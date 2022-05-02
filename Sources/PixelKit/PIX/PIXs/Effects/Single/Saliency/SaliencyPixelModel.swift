//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct SaliencyPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Saliency"
    public var typeName: String = "pix-effect-single-saliency"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var style: SaliencyPIX.SaliencyStyle = .attention
}

extension SaliencyPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case style
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .style:
                    let live: LiveEnum<SaliencyPIX.SaliencyStyle> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    style = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(SaliencyPIX.SaliencyStyle.self, forKey: .style)
    }
}

extension SaliencyPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard style == pixelModel.style else { return false }
        return true
    }
}

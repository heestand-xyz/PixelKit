//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ConvertPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Convert"
    public var typeName: String = "pix-effect-single-convert"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var mode: ConvertPIX.ConvertMode = .squareToCircle
}

extension ConvertPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case mode
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .mode:
                    let live: LiveEnum<ConvertPIX.ConvertMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    mode = live.wrappedValue
                }
            }
            return
        }
        
        mode = try container.decode(ConvertPIX.ConvertMode.self, forKey: .mode)
    }
}

extension ConvertPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard mode == pixelModel.mode else { return false }
        return true
    }
}

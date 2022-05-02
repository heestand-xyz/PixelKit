//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ThresholdPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Threshold"
    public var typeName: String = "pix-effect-single-threshold"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var threshold: CGFloat = 0.5
}

extension ThresholdPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case threshold
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .threshold:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    threshold = live.wrappedValue
                }
            }
            return
        }
        
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
    }
}

extension ThresholdPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard threshold == pixelModel.threshold else { return false }
        return true
    }
}

//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct FeedbackPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Feedback"
    public var typeName: String = "pix-effect-single-feedback"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local

    public var feedbackInputNodeReference: NodeReference?
    public var feedActive: Bool = true
}

extension FeedbackPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case feedbackInputNodeReference
        case feedActive
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)

        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .feedActive:
                    guard let live = liveWrap as? LiveBool else { continue }
                    feedActive = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        feedbackInputNodeReference = try container.decode(NodeReference.self, forKey: .feedbackInputNodeReference)
        feedActive = try container.decode(Bool.self, forKey: .feedActive)
    }
}

extension FeedbackPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard feedbackInputNodeReference == pixelModel.feedbackInputNodeReference else { return false }
        guard feedActive == pixelModel.feedActive else { return false }
        return true
    }
}

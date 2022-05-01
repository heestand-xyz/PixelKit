//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct TimeMachinePixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Time Machine"
    public var typeName: String = "pix-effect-merger-time-machine"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
    
    // MARK: Local
    
    public var seconds: CGFloat = 1.0
}

extension TimeMachinePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case seconds
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .seconds:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    seconds = live.wrappedValue
                }
            }
            return
        }
        
        seconds = try container.decode(CGFloat.self, forKey: .seconds)
    }
}

extension TimeMachinePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMergerEffectEqual(to: pixelModel) else { return false }
        guard seconds == pixelModel.seconds else { return false }
        return true
    }
}

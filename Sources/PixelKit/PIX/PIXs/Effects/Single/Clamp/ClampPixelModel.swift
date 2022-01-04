//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ClampPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Clamp"
    public var typeName: String = "pix-effect-single-clamp"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var low: CGFloat = 0.0
    public var high: CGFloat = 1.0
    public var clampAlpha: Bool = false
    
}

extension ClampPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case low
        case high
        case clampAlpha
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .low:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    low = live.wrappedValue
                case .high:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    high = live.wrappedValue
                case .clampAlpha:
                    guard let live = liveWrap as? LiveBool else { continue }
                    clampAlpha = live.wrappedValue
                }
            }
            return
        }
        
        low = try container.decode(CGFloat.self, forKey: .low)
        high = try container.decode(CGFloat.self, forKey: .high)
        clampAlpha = try container.decode(Bool.self, forKey: .clampAlpha)
    }
}

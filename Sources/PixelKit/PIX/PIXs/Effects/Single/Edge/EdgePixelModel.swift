//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct EdgePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Edge"
    public var typeName: String = "pix-effect-single-edge"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .hold
    
    // MARK: Local
    
    public var strength: CGFloat = 10.0
    public var distance: CGFloat = 1.0
    public var colored: Bool = false
    public var transparent: Bool = false
    public var includeAlpha: Bool = false
    public var sobel: Bool = false
}

extension EdgePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case strength
        case distance
        case colored
        case transparent
        case includeAlpha
        case sobel
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .strength:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    strength = live.wrappedValue
                case .distance:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    distance = live.wrappedValue
                case .colored:
                    guard let live = liveWrap as? LiveBool else { continue }
                    colored = live.wrappedValue
                case .transparent:
                    guard let live = liveWrap as? LiveBool else { continue }
                    transparent = live.wrappedValue
                case .includeAlpha:
                    guard let live = liveWrap as? LiveBool else { continue }
                    includeAlpha = live.wrappedValue
                case .sobel:
                    guard let live = liveWrap as? LiveBool else { continue }
                    sobel = live.wrappedValue
                }
            }
            return
        }
        
        strength = try container.decode(CGFloat.self, forKey: .strength)
        distance = try container.decode(CGFloat.self, forKey: .distance)
        colored = try container.decode(Bool.self, forKey: .colored)
        transparent = try container.decode(Bool.self, forKey: .transparent)
        includeAlpha = try container.decode(Bool.self, forKey: .includeAlpha)
        sobel = try container.decode(Bool.self, forKey: .sobel)
    }
}

extension EdgePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard strength == pixelModel.strength else { return false }
        guard distance == pixelModel.distance else { return false }
        guard colored == pixelModel.colored else { return false }
        guard transparent == pixelModel.transparent else { return false }
        guard includeAlpha == pixelModel.includeAlpha else { return false }
        guard sobel == pixelModel.sobel else { return false }
        return true
    }
}

//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ResolutionPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Resolution"
    public var typeName: String = "pix-effect-single-resolution"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = ._128
    public var resolutionMultiplier: CGFloat = 1
    public var inheritResolution: Bool = false
    public var placement: Placement = .fit
}

extension ResolutionPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case resolutionMultiplier
        case inheritResolution
        case placement
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    resolution = live.wrappedValue
                case .resolutionMultiplier:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    resolutionMultiplier = live.wrappedValue
                case .inheritResolution:
                    guard let live = liveWrap as? LiveBool else { continue }
                    inheritResolution = live.wrappedValue
                case .placement:
                    let live: LiveEnum<Placement> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    placement = live.wrappedValue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        resolutionMultiplier = try container.decode(CGFloat.self, forKey: .resolutionMultiplier)
        inheritResolution = try container.decode(Bool.self, forKey: .inheritResolution)
        placement = try container.decode(Placement.self, forKey: .placement)
    }
}

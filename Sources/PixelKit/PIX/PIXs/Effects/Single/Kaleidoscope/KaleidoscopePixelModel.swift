//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct KaleidoscopePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Kaleidoscope"
    public var typeName: String = "pix-effect-single-kaleidoscope"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .mirror
    
    // MARK: Local
    
    public var divisions: Int = 12
    public var mirror: Bool = true
    public var rotation: CGFloat = 0.0
    public var position: CGPoint = .zero
}

extension KaleidoscopePixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case divisions
        case mirror
        case rotation
        case position
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .divisions:
                    guard let live = liveWrap as? LiveInt else { continue }
                    divisions = live.wrappedValue
                case .mirror:
                    guard let live = liveWrap as? LiveBool else { continue }
                    mirror = live.wrappedValue
                case .rotation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    rotation = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                }
            }
            return
        }
        
        divisions = try container.decode(Int.self, forKey: .divisions)
        mirror = try container.decode(Bool.self, forKey: .mirror)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        position = try container.decode(CGPoint.self, forKey: .position)
    }
}

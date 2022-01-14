//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ArrayPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Array"
    public var typeName: String = "pix-effect-multi-array"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var blendMode: BlendMode = .add
    public var backgroundColor: PixelColor = .black
    public var coordinates: [Coordinate] = []
}

extension ArrayPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case blendMode
        case backgroundColor
        case coordinates
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMultiEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        coordinates = try container.decode([Coordinate].self, forKey: .coordinates)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .blendMode:
                    let live: LiveEnum<BlendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    blendMode = live.wrappedValue
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    backgroundColor = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        blendMode = try container.decode(BlendMode.self, forKey: .blendMode)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
    }
}

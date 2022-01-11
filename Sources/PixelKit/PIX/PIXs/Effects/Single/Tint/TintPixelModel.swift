//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct TintPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Tint"
    public var typeName: String = "pix-effect-single-tint"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var color: PixelColor = PixelColor(red: 1.0, green: 0.5, blue: 0.0)
}

extension TintPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case color
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .color:
                    guard let live = liveWrap as? LiveColor else { continue }
                    color = live.wrappedValue
                }
            }
            return
        }
        
        color = try container.decode(PixelColor.self, forKey: .color)
    }
}

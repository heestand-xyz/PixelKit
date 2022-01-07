//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelMergerEffectModel = PixelModel & NodeMergerEffectModel

struct PixelMergerEffectModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case placement
    }
    
    static func decode(from decoder: Decoder, model: PixelMergerEffectModel) throws -> PixelMergerEffectModel {
        
        var model: PixelMergerEffectModel = try PixelEffectModelDecoder.decode(from: decoder, model: model) as! PixelMergerEffectModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .placement:
                    guard let live = liveWrap as? LiveEnum<Placement> else { continue }
                    model.placement = live.wrappedValue
                }
            }
            return model
        }
        
        model.placement = try container.decode(Placement.self, forKey: .placement)
        
        return model
    }
    
}

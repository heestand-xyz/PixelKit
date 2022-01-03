//
//  Created by Anton Heestand on 2022-01-03.
//

import RenderKit

public typealias PixelEffectModel = PixelModel & NodeEffectModel

struct PixelEffectModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case inputNodeReferences
        case outputNodeReferences
    }
    
    static func decode(from decoder: Decoder, model: PixelEffectModel) throws -> PixelEffectModel {
        
        var model: PixelEffectModel = try PixelModelDecoder.decode(from: decoder, model: model) as! PixelEffectModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return model
        }
        
        model.inputNodeReferences = try container.decode([NodeReference].self, forKey: .inputNodeReferences)
        model.outputNodeReferences = try container.decode([NodeReference].self, forKey: .outputNodeReferences)

        return model
    }
}

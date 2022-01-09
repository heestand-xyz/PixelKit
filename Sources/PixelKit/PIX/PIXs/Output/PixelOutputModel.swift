//
//  Created by Anton Heestand on 2022-01-03.
//

import RenderKit

public typealias PixelOutputModel = PixelModel & NodeOutputModel

struct PixelOutputModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case outputNodeReferences
    }
    
    static func decode(from decoder: Decoder, model: PixelOutputModel) throws -> PixelOutputModel {
        
        var model: PixelOutputModel = try PixelModelDecoder.decode(from: decoder, model: model) as! PixelOutputModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return model
        }
        
        model.outputNodeReferences = try container.decode([NodeReference].self, forKey: .outputNodeReferences)

        return model
    }
}

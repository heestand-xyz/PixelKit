//
//  Created by Anton Heestand on 2021-12-13.
//

import RenderKit

public typealias PixelContentModel = PixelModel & NodeContentModel

struct PixelContentModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case outputNodeReferences
    }
    
    static func decode(from decoder: Decoder, model: PixelContentModel) throws -> PixelContentModel {
        
        var model: PixelContentModel = try PixelModelDecoder.decode(from: decoder, model: model) as! PixelContentModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return model
        }
        
        model.outputNodeReferences = try container.decode([NodeReference].self, forKey: .outputNodeReferences)
        
        return model
    }
}

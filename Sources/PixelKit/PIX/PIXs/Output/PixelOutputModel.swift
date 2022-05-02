//
//  Created by Anton Heestand on 2022-01-03.
//

import RenderKit

public typealias PixelOutputModel = PixelModel & NodeClosingModel

public struct PixelOutputModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case inputNodeReferences
    }
    
    public static func decode(from decoder: Decoder, model: PixelOutputModel) throws -> PixelOutputModel {
        
        var model: PixelOutputModel = try PixelModelDecoder.decode(from: decoder, model: model) as! PixelOutputModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return model
        }
        
        model.inputNodeReferences = try container.decode([NodeReference].self, forKey: .inputNodeReferences)

        return model
    }
}

extension PixelModel {
    
    func isPixelOutputEqual(to pixelModel: PixelOutputModel) -> Bool {
        guard isPixelEqual(to: pixelModel) else { return false }
        return true
    }
}

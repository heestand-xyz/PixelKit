//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelSingleEffectModel = PixelModel & NodeSingleEffectModel

struct PixelSingleEffectModelDecoder {
    
    static func decode(from decoder: Decoder, model: PixelSingleEffectModel) throws -> PixelSingleEffectModel {
        
        try PixelEffectModelDecoder.decode(from: decoder, model: model) as! PixelSingleEffectModel
    }
}

extension PixelModel {
    
    func isPixelSingleEffectEqual(to pixelModel: PixelSingleEffectModel) -> Bool {
        guard let self = self as? PixelSingleEffectModel else { return false }
        guard isPixelEffectEqual(to: pixelModel) else { return false }
        return true
    }
}

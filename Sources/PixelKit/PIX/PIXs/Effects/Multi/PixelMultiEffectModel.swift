//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelMultiEffectModel = PixelModel & NodeMultiEffectModel

struct PixelMultiEffectModelDecoder {
    
    static func decode(from decoder: Decoder, model: PixelMultiEffectModel) throws -> PixelMultiEffectModel {
        
        try PixelEffectModelDecoder.decode(from: decoder, model: model) as! PixelMultiEffectModel
    }
}

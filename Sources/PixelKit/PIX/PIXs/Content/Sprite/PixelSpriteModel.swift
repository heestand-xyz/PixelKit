//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelSpriteModel = PixelContentModel & NodeSpriteContentModel

struct PixelSpriteModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case backgroundColor
    }
    
    static func decode(from decoder: Decoder, model: PixelSpriteModel) throws -> PixelSpriteModel {
        
        var model: PixelSpriteModel = try PixelContentModelDecoder.decode(from: decoder, model: model) as! PixelSpriteModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    model.resolution = live.wrappedValue
                case .backgroundColor:
                    continue
                }
            }
            return model
        }
        
        model.resolution = try container.decode(Resolution.self, forKey: .resolution)
        model.backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
        
        return model
    }
}

extension PixelModel {
    
    func isPixelSpriteEqual(to pixelModel: PixelSpriteModel) -> Bool {
        guard let self = self as? PixelSpriteModel else { return false }
        guard isPixelContentEqual(to: pixelModel) else { return false }
        guard self.resolution == pixelModel.resolution else { return false }
        guard self.backgroundColor == pixelModel.backgroundColor else { return false }
        return true
    }
}

//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelCustomModel = PixelContentModel & NodeCustomContentModel

struct PixelCustomModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case backgroundColor
    }
    
    static func decode(from decoder: Decoder, model: PixelCustomModel) throws -> PixelCustomModel {
        
        var model: PixelCustomModel = try PixelContentModelDecoder.decode(from: decoder, model: model) as! PixelCustomModel
        
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
                    guard let live = liveWrap as? LiveColor else { continue }
                    model.backgroundColor = live.wrappedValue
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
    
    func isPixelCustomEqual(to pixelModel: PixelCustomModel) -> Bool {
        guard let self = self as? PixelCustomModel else { return false }
        guard isPixelContentEqual(to: pixelModel) else { return false }
        guard self.resolution == pixelModel.resolution else { return false }
        guard self.backgroundColor == pixelModel.backgroundColor else { return false }
        return true
    }
}

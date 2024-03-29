//
//  Created by Anton Heestand on 2021-12-13.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelGeneratorModel = PixelContentModel & NodeGeneratorContentModel

public struct PixelGeneratorModelDecoder {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case premultiply
        case resolution
        case backgroundColor
        case color
    }
    
    public static func decode(from decoder: Decoder, model: PixelGeneratorModel) throws -> PixelGeneratorModel {
        
        var model: PixelGeneratorModel = try PixelContentModelDecoder.decode(from: decoder, model: model) as! PixelGeneratorModel
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .premultiply:
                    guard let live = liveWrap as? LiveBool else { continue }
                    model.premultiply = live.wrappedValue
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    model.resolution = live.wrappedValue
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    model.backgroundColor = live.wrappedValue
                case .color:
                    guard let live = liveWrap as? LiveColor else { continue }
                    model.color = live.wrappedValue
                }
            }
            return model
        }
        
        model.premultiply = try container.decode(Bool.self, forKey: .premultiply)
        model.resolution = try container.decode(Resolution.self, forKey: .resolution)
        model.backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
        model.color = try container.decode(PixelColor.self, forKey: .color)
        
        return model
    }
}

extension PixelModel {
    
    public func isPixelGeneratorEqual(to pixelModel: PixelGeneratorModel) -> Bool {
        guard let self = self as? PixelGeneratorModel else { return false }
        guard isPixelContentEqual(to: pixelModel) else { return false }
        guard self.premultiply == pixelModel.premultiply else { return false }
        guard self.resolution == pixelModel.resolution else { return false }
        guard self.backgroundColor == pixelModel.backgroundColor else { return false }
        guard self.color == pixelModel.color else { return false }
        return true
    }
}

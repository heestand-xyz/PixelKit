//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import RenderKit

public protocol PixelModel: NodeModel {
    var viewInterpolation: ViewInterpolation { get set }
    var interpolation: PixelInterpolation { get set }
    var extend: ExtendMode { get set }
}

struct PixelModelDecoder {
    
    enum CodingKeys: CodingKey {
        case viewInterpolation
        case interpolation
        case extend
    }
    
    static func decode(from decoder: Decoder, model: PixelModel) throws -> PixelModel {
        
        var model: PixelModel = model
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        model.viewInterpolation = try container.decode(ViewInterpolation.self, forKey: .viewInterpolation)
        model.interpolation = try container.decode(PixelInterpolation.self, forKey: .interpolation)
        model.extend = try container.decode(ExtendMode.self, forKey: .extend)
        
        return model
    }
    
//    enum LiveCodingKeys: CodingKey {
//        case liveList
//    }
//    
//    static func decodeLiveValues(from decoder: Decoder, model: PixelModel) throws -> [String: Floatable] {
//        
//        
//    }
}

@available(*, deprecated)
struct TempPixelModel: PixelModel {
    
    /// Global
    
    var id: UUID = UUID()
    var name: String
    let typeName: String
    var bypass: Bool = false
    
    var viewInterpolation: ViewInterpolation = .linear
    var interpolation: PixelInterpolation = .linear
    var extend: ExtendMode = .zero
    
}

//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-12-13.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public typealias PixelGeneratorModel = PixelModel & NodeGeneratorContentModel

struct PixelGeneratorModelDecoder {
    
    enum CodingKeys: CodingKey {
        case premultiply
        case resolution
        case backgroundColor
        case color
    }
    
    static func decode(from decoder: Decoder, model: PixelGeneratorModel) throws -> PixelGeneratorModel {
        
        var model: PixelGeneratorModel = model
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        model.premultiply = try container.decode(Bool.self, forKey: .premultiply)
        model.resolution = try container.decode(Resolution.self, forKey: .resolution)
        model.backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
        model.color = try container.decode(PixelColor.self, forKey: .color)
        
        return try PixelModelDecoder.decode(from: decoder, model: model) as! PixelGeneratorModel
    }
}

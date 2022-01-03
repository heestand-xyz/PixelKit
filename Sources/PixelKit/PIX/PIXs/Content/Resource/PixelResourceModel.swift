//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-12-13.
//

import Foundation
import RenderKit

public typealias PixelResourceModel = PixelContentModel & NodeResourceContentModel

struct PixelResourceModelDecoder {
    
    static func decode(from decoder: Decoder, model: PixelResourceModel) throws -> PixelResourceModel {
        
        try PixelModelDecoder.decode(from: decoder, model: model) as! PixelResourceModel
    }
}

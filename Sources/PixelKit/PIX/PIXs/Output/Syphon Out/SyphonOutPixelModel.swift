//
//  Created by Anton Heestand on 2022-01-09.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct SyphonOutPixelModel: PixelOutputModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Syphon Out"
    public var typeName: String = "pix-output-syphon-out"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
}

extension SyphonOutPixelModel {
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelOutputModelDecoder.decode(from: decoder, model: self) as! Self
    }
}

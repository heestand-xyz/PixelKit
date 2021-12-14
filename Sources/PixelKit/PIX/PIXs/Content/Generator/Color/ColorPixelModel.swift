//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public struct ColorPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Color"
    public var typeName: String = "pix-content-generator-color"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var premultiply: Bool = true
    public var resolution: Resolution = .auto(render: PixelKit.main.render)

    public var backgroundColor: PixelColor = .black
    public var color: PixelColor = .white
}

extension ColorPixelModel {
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
    }
}


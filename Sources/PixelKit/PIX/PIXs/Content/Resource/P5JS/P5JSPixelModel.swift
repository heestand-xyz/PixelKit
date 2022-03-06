//
//  Created by Anton Heestand on 2022-03-06.
//

#if !os(tvOS)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct P5JSPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "p5.js"
    public var typeName: String = "pix-content-resource-p5js"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
}

extension P5JSPixelModel {
        
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
    }
}

#endif

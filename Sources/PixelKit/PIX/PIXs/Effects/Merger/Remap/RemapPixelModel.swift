//
//  Created by Anton Heestand on 2022-01-07.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct RemapPixelModel: PixelMergerEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Remap"
    public var typeName: String = "pix-effect-merger-remap"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var placement: Placement = .fit
}

extension RemapPixelModel {
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMergerEffectModelDecoder.decode(from: decoder, model: self) as! Self
    }
}

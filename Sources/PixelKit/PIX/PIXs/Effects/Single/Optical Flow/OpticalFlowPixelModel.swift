//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct OpticalFlowPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Optical Flow"
    public var typeName: String = "pix-effect-single-optical-flow"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
}

extension OpticalFlowPixelModel {
    
    public init(from decoder: Decoder) throws {
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
    }
}

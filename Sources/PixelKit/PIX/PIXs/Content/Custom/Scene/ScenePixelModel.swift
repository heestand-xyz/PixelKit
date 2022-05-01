//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ScenePixelModel: PixelCustomModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Scene"
    public var typeName: String = "pix-content-custom-scene"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var resolution: Resolution = .auto
    public var backgroundColor: PixelColor = .black
}

extension ScenePixelModel {
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelCustomModelDecoder.decode(from: decoder, model: self) as! Self
        
    }
}

extension ScenePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelCustomEqual(to: pixelModel) else { return false }
        return true
    }
}

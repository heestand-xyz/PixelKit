//
//  Created by Anton Heestand on 2022-01-02.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct DepthCameraPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Depth Camera"
    public var typeName: String = "pix-content-resource-depth-camera"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
}

extension DepthCameraPixelModel {
    
    public init(from decoder: Decoder) throws {
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
    }
}

extension DepthCameraPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        return true
    }
}

#endif

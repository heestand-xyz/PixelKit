//
//  Created by Anton Heestand on 2022-01-03.
//

#if os(iOS)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct StreamInPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Stream In"
    public var typeName: String = "pix-content-resource-stream-in"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
}

extension StreamInPixelModel {
    
    public init(from decoder: Decoder) throws {
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
    }
}

extension StreamInPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        return true
    }
}

#endif

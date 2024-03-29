//
//  Created by Anton Heestand on 2022-01-02.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ImagePixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Image"
    public var typeName: String = "pix-content-resource-image"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resizePlacement: Texture.ImagePlacement = .fit
    public var resizeResolution: Resolution?
}

extension ImagePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resizePlacement
        case resizeResolution
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        resizePlacement = try container.decode(Texture.ImagePlacement.self, forKey: .resizePlacement)
        resizeResolution = try container.decodeIfPresent(Resolution?.self, forKey: .resizeResolution) ?? nil
    }
}

extension ImagePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        guard resizePlacement == pixelModel.resizePlacement else { return false }
        guard resizeResolution == pixelModel.resizeResolution else { return false }
        return true
    }
}

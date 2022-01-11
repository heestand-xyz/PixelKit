//
//  Created by Anton Heestand on 2022-01-03.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MultiCameraPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Multi Camera"
    public var typeName: String = "pix-content-resource-multi-camera"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var camera: CameraPIX.Camera = .front
}

extension MultiCameraPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case camera
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        camera = try container.decode(CameraPIX.Camera.self, forKey: .camera)
    }
}

#endif

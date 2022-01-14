//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct VideoPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Video"
    public var typeName: String = "pix-content-resource-video"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var loops: Bool = true
    public var volume: CGFloat = 1.0
    
}

extension VideoPixelModel {
        
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case loops
        case volume
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        loops = try container.decode(Bool.self, forKey: .loops)
        volume = try container.decode(CGFloat.self, forKey: .volume)
        
    }
    
}

//
//  Created by Anton Heestand on 2022-01-09.
//

#if os(iOS)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct StreamOutPixelModel: PixelOutputModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Stream Out"
    public var typeName: String = "pix-output-stream-out"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local

    public var quality: CGFloat = 0.5
}

extension StreamOutPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case quality
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelOutputModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        quality = try container.decode(CGFloat.self, forKey: .quality)
    }
}

#endif

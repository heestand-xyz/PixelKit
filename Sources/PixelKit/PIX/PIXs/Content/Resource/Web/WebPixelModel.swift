//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct WebPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Web"
    public var typeName: String = "pix-content-resource-web"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
    public var url: URL = URL(string: "https://google.com/")!
    
}

extension WebPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case url
    }

    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        url = try container.decode(URL.self, forKey: .url)
        
    }

}

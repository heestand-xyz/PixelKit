//
//  Created by Anton Heestand on 2021-12-12.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

public struct ArcPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Arc"
    public var typeName: String = "pix-content-generator-arc"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var premultiply: Bool = true
    public var resolution: Resolution = .auto(render: PixelKit.main.render)

    public var backgroundColor: PixelColor = .black
    public var color: PixelColor = .white
    
    // MARK: Local
    
    public var position: CGPoint = .zero
    public var radius: CGFloat = 0.25
    public var angleFrom: CGFloat = -0.125
    public var angleTo: CGFloat = 0.125
    public var angleOffset: CGFloat = 0.0
    public var edgeRadius: CGFloat = 0.0
    public var edgeColor: PixelColor = .gray
}

extension ArcPixelModel {
    
    enum CodingKeys: CodingKey {
        case position
        case radius
        case angleFrom
        case angleTo
        case angleOffset
        case edgeRadius
        case edgeColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decode(CGPoint.self, forKey: .position)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        angleFrom = try container.decode(CGFloat.self, forKey: .angleFrom)
        angleTo = try container.decode(CGFloat.self, forKey: .angleTo)
        angleOffset = try container.decode(CGFloat.self, forKey: .angleOffset)
        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
        edgeColor = try container.decode(PixelColor.self, forKey: .edgeColor)
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! ArcPixelModel
    }
}

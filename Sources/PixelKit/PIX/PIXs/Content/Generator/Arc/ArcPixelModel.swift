//
//  Created by Anton Heestand on 2021-12-12.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

struct ArcPixelModel: PixelModel, NodeGeneratorContentModel {
    
    /// Global
    
    let id: UUID = UUID()
    var name: String
    let typeName: String
    var bypass: Bool = false
    
    var outputNodeReferences: [NodeReference] = []
    
    var premultiply: Bool = true
    var resolution: Resolution

    var viewInterpolation: ViewInterpolation = .linear
    var interpolation: PixelInterpolation = .linear
    var extend: ExtendMode = .zero
    
    /// Local
    
    var position: CGPoint = .zero
    var radius: CGFloat = 0.25
    var angleFrom: CGFloat = -0.125
    var angleTo: CGFloat = 0.125
    var angleOffset: CGFloat = 0.0
    var edgeRadius: CGFloat = 0.0
    var edgeColor: PixelColor = .gray
}

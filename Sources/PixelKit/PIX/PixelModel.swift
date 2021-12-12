//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import RenderKit

public protocol PixelModel: NodeModel {
    var viewInterpolation: ViewInterpolation { get set }
    var interpolation: PixelInterpolation { get set }
    var extend: ExtendMode { get set }
}

@available(*, deprecated)
struct TempPixelModel: PixelModel {
    
    /// Global
    
    let id: UUID = UUID()
    var name: String
    let typeName: String
    var bypass: Bool = false
    
    var viewInterpolation: ViewInterpolation = .linear
    var interpolation: PixelInterpolation = .linear
    var extend: ExtendMode = .zero
    
}

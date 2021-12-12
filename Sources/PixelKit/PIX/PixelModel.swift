//
//  Created by Anton Heestand on 2021-02-04.
//

import RenderKit

public protocol PixelModel: NodeModel {
    var viewInterpolation: ViewInterpolation { get set }
    var interpolation: PixelInterpolation { get set }
    var extend: ExtendMode { get set }
}

//
//  Created by Anton Heestand on 2021-02-03.
//

import RenderKit
import Resolution

#if swift(>=5.5)
@resultBuilder
public struct PIXBuilder {
    public static func buildBlock(_ pixs: (PIX & NODEOut)...) -> [(PIX & NODEOut)] {
        pixs
    }
    public static func buildBlock(_ pix: (PIX & NODEOut)) -> (PIX & NODEOut) {
        pix
    }
}
#endif

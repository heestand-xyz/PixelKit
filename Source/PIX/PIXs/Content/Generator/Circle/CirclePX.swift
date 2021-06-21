
//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public struct CirclePX: PXOut, PXOOutRep {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    let radius: CGFloat
    
    public init(radius: CGFloat) {
        print("PX Circle Init", radius)
        self.radius = radius
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Circle Make")
        let object: PXObject = context.coordinator
        let pixView: PIXView = object.pix.pixView
        setup(object: object)
        pxObjectExtractor.object = object
        return pixView
    }
    
    func setup(object: PXObject) {
        object.update = { transaction, px in
            let px = px as! CirclePX
            let circlePix: CirclePIX = object.pix as! CirclePIX
            if !transaction.disablesAnimations,
               let animation: Animation = transaction.animation {
                print("PX Circle Update Animation", px.radius)
                PXHelper.animate(animation: animation, timer: &object.timer) { fraction in
                    PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: px, pix: circlePix, at: fraction)
                }
            } else {
                print("PX Circle Update Direct")
                circlePix.radius = px.radius
            }
        }
    }

    public func updateView(_ pixView: PIXView, context: Context) {
        print("PX Circle Update")
        let object: PXObject = context.coordinator
        object.update?(context.transaction, self)
    }
    
    public func makeCoordinator() -> PXObject {
        PXObject(pix: CirclePIX(at: .square(1000)))
    }
}

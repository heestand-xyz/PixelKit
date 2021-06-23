
//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public struct CirclePX: PXView {
    
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

        pxObjectExtractor.object = object
        return pixView
    }
    
    public func animate(object: PXObject, transaction: Transaction) {

        let pix: CirclePIX = object.pix as! CirclePIX

        if !transaction.disablesAnimations,
           let animation: Animation = transaction.animation {
            print("PX Circle Animate", radius)
            PXHelper.animate(animation: animation, timer: &object.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: pix, at: fraction)
            }
        } else {
            print("PX Circle Animate Direct", radius)
            pix.radius = radius
        }
    }

    public func updateView(_ pixView: PIXView, context: Context) {
        print("PX Circle Update")
        let object: PXObject = context.coordinator
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObject {
        PXObject(pix: CirclePIX(at: .square(1000)))
    }
}


//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public struct CirclePX: PXOut, PXOOutRep {
    
    public var object: PXObject {
        let slug: String = String(describing: Mirror(reflecting: self))
        print("PX Cicle Slug", slug)
        return PXStore.store[slug] ?? {
            let pix = CirclePIX()
            print("PX Circle New....................", slug)
            let object = PXObject(pix: pix)
            PXStore.store[slug] = object
            return object
        }()
    }
    
    let radius: CGFloat
    
    public init(radius: CGFloat) {
        print("PX Circle Init", radius)
        self.radius = radius
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Circle Make")
        setup(object: object)
        return object.pix.pixView
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
        object.update?(context.transaction, self)
    }
}

//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public final class BlurPX<PXO: PXOOutRep>: PXIn, PXOut, ViewRepresentable {
    
    public var object: PXObject {
        let slug: String = String(describing: self)
        return PXStore.store[slug] ?? {
            let pix = BlurPIX()
            print("PX Blur New....................", slug)
            let object = PXObject(pix: pix)
            PXStore.store[slug] = object
            return object
        }()
    }
    
    public let inPx: () -> (PXO)

    let radius: CGFloat

    public init(inPx: @escaping () -> (PXO), radius: CGFloat) {
        print("PX Blur Init")
        self.inPx = inPx
        self.radius = radius
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Blur Make")
        setup()
        let pixView: PIXView = object.pix.pixView
        let inCoordinator: PXObject = inPx().object
        connect(from: inCoordinator, to: object)
        let host = UINSHostingView(rootView: inPx())
        pixView.addSubview(host.view)
        return pixView
    }

    func setup() {
        object.update = { transaction, px in
            let px = px as! BlurPX
            let blurPix: BlurPIX = self.object.pix as! BlurPIX
            if !transaction.disablesAnimations,
               let animation: Animation = transaction.animation {
                print("PX Blur Update Animation", px.radius)
                PXHelper.animate(animation: animation, timer: &self.object.timer) { fraction in
                    PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: px, pix: blurPix, at: fraction)
                }
            } else {
                print("PX Blur Update Direct")
                blurPix.radius = px.radius
            }
        }
    }

    public func connect(from connectObject: PXObject,
                        to object: PXObject) {
        let blurPix: BlurPIX = object.pix as! BlurPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if blurPix.input?.id != inPix.id {
                blurPix.input = inPix
                print("PX Blur Connected!")
            }
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Blur Update")
        object.update?(context.transaction, self)
        let inObject: PXObject = inPx().object
        inObject.update?(context.transaction, inPx())
    }
}

@available(iOS 14.0, *)
public extension PXOOutRep {

    func pxBlur(radius: CGFloat) -> BlurPX<Self> {
        print("PX Blur Func")
        return BlurPX(inPx: { self }, radius: radius)
    }
}


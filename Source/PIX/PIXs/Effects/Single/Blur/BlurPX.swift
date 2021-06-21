//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public final class BlurPX<PXO: PXOOutRep>: PXIn, PXOOutRep {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPx: PXO

    let radius: CGFloat

    public init(inPx: PXO, radius: CGFloat) {
        print("PX Blur Init", radius)
        self.inPx = inPx
        self.radius = radius
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Blur Make")
        let objectEffect: PXObjectEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
        var connected: Bool = false
        let host = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPx, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
            guard let connectObject = connectObject else { return }
            guard !connected else { return }
            self.connect(from: connectObject, to: objectEffect)
            connected = true
        })))
        pixView.addSubview(host.view)
        
        pxObjectExtractor.object = objectEffect
        return pixView
    }
    
    public func animate(object: PXObject, transaction: Transaction) {
        
        let pix: BlurPIX = object.pix as! BlurPIX
        
        if !transaction.disablesAnimations,
           let animation: Animation = transaction.animation {
            print("PX Blur Animate", radius)
            PXHelper.animate(animation: animation, timer: &object.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: pix, at: fraction)
            }
        } else {
            print("PX Blur Animate Direct", radius)
            pix.radius = radius
        }
        
        let objectEffect: PXObjectEffect = object as! PXObjectEffect
        if let inputObject: PXObject = objectEffect.inputObject {
            inPx.animate(object: inputObject, transaction: transaction)
        }
    }

    public func connect(from connectObject: PXObject,
                        to objectEffect: PXObjectEffect) {
        objectEffect.inputObject = connectObject
        let pix: BlurPIX = objectEffect.pix as! BlurPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if pix.input?.id != inPix.id {
                pix.input = inPix
                print("PX Blur Connected!")
            }
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Blur Update")
        let object: PXObjectEffect = context.coordinator
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObjectEffect {
        PXObjectEffect(pix: BlurPIX())
    }
}

@available(iOS 14.0, *)
public extension PXOOutRep {

    func pxBlur(radius: CGFloat) -> BlurPX<Self> {
        print("PX Blur Func")
        return BlurPX(inPx: self, radius: radius)
    }
}


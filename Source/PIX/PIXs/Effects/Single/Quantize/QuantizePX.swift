//
//  Created by Anton Heestand on 2021-06-21.
//

import Foundation
import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public final class QuantizePX<PV: PXView>: PXIn, PXView {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPx: PV

    let fraction: CGFloat

    public init(inPx: PV, fraction: CGFloat) {
        print("PX Quantize Init", fraction)
        self.inPx = inPx
        self.fraction = fraction
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Quantize Make")
        let objectEffect: PXObjectEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
        var connected: Bool = false
        let host = UINSHostingView(rootView: PXObjectExtractorView(content: inPx, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
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
        
        let pix: QuantizePIX = object.pix as! QuantizePIX
        
        if !transaction.disablesAnimations,
           let animation: Animation = transaction.animation {
            print("PX Quantize Animate", fraction)
            PXHelper.animate(animation: animation, timer: &object.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.fraction, pixKeyPath: \.fraction, px: self, pix: pix, at: fraction)
            }
        } else {
            print("PX Quantize Animate Direct", fraction)
            pix.fraction = fraction
        }
        
        let objectEffect: PXObjectEffect = object as! PXObjectEffect
        if let inputObject: PXObject = objectEffect.inputObject {
            inPx.animate(object: inputObject, transaction: transaction)
        }
    }

    public func connect(from connectObject: PXObject,
                        to objectEffect: PXObjectEffect) {
        objectEffect.inputObject = connectObject
        let pix: QuantizePIX = objectEffect.pix as! QuantizePIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if pix.input?.id != inPix.id {
                pix.input = inPix
                print("PX Quantize Connected!")
            }
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Quantize Update")
        let object: PXObjectEffect = context.coordinator
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObjectEffect {
        PXObjectEffect(pix: QuantizePIX())
    }
}

@available(iOS 14.0, *)
public extension PXView {

    func pxQuantize(fraction: CGFloat) -> QuantizePX<Self> {
        print("PX Quantize Func")
        return QuantizePX(inPx: self, fraction: fraction)
    }
}


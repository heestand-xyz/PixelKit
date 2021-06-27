//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-06-21.
//

#if swift(>=5.5)

import Foundation
import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public final class BlendPX<PVA: PXView, PVB: PXView>: PXInAB, PXView {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPxA: PVA
    public let inPxB: PVB

    let blendMode: RenderKit.BlendMode

    public init(blendMode: RenderKit.BlendMode,
                leading inPxA: () -> (PVA),
                trailing inPxB: () -> (PVB)) {
        print("PX Blend Init")
        self.inPxA = inPxA()
        self.inPxB = inPxB()
        self.blendMode = blendMode
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Blend Make")
        let objectEffect: PXObjectMergerEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
        func setupConnectionB() {
            var connectedB: Bool = false
            let hostB = UINSHostingView(rootView: PXObjectExtractorView(content: self.inPxB, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
                guard let connectObjectB = connectObject else { return }
                guard !connectedB else { return }
                self.connectB(from: connectObjectB, to: objectEffect)
                connectedB = true
            })))
            guard let view: UINSView = hostB.view else { return }
            pixView.addSubview(view)
        }
        
        func setupConnectionA(_ done: @escaping () -> ()) {
            var connectedA: Bool = false
            let hostA = UINSHostingView(rootView: PXObjectExtractorView(content: inPxA, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
                guard let connectObjectA = connectObject else { return }
                guard !connectedA else { return }
                self.connectA(from: connectObjectA, to: objectEffect)
                connectedA = true
                done()
            })))
            guard let view: UINSView = hostA.view else { fatalError() }
            pixView.addSubview(view)
        }
        
        setupConnectionA {
            setupConnectionB()
        }
        
        pxObjectExtractor.object = objectEffect
        return pixView
    }
    
    public func animate(object: PXObject, transaction: Transaction) {
        
        let pix: BlendPIX = object.pix as! BlendPIX
        
//        if !transaction.disablesAnimations,
//           let animation: Animation = transaction.animation {
//            print("PX Blend Animate", fraction)
//            PXHelper.animate(animation: animation, timer: &object.timer) { fraction in
//                PXHelper.motion(pxKeyPath: \.fraction, pixKeyPath: \.fraction, px: self, pix: pix, at: fraction)
//            }
//        } else {
            print("PX Blend Animate Direct", blendMode)
            pix.blendMode = blendMode
//        }
        
        let objectEffect: PXObjectMergerEffect = object as! PXObjectMergerEffect
        if let inputObjectA: PXObject = objectEffect.inputObjectA {
            inPxA.animate(object: inputObjectA, transaction: transaction)
        }
        if let inputObjectB: PXObject = objectEffect.inputObjectB {
            inPxB.animate(object: inputObjectB, transaction: transaction)
        }
    }

    public func connectA(from connectObject: PXObject,
                         to objectEffect: PXObjectMergerEffect) {
        objectEffect.inputObjectA = connectObject
        let pix: BlendPIX = objectEffect.pix as! BlendPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if pix.inputA?.id != inPix.id {
                pix.inputA = inPix
                print("PX Blend Connected A!")
            }
        }
    }
    
    public func connectB(from connectObject: PXObject,
                         to objectEffect: PXObjectMergerEffect) {
        objectEffect.inputObjectB = connectObject
        let pix: BlendPIX = objectEffect.pix as! BlendPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if pix.inputB?.id != inPix.id {
                pix.inputB = inPix
                print("PX Blend Connected B!")
            }
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Blend Update")
        let object: PXObjectMergerEffect = context.coordinator
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObjectMergerEffect {
        PXObjectMergerEffect(pix: BlendPIX())
    }
}

#endif

//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-06-21.
//

import Foundation
import SwiftUI
import RenderKit
import PixelColor

@available(iOS 14.0, *)
public final class BlendPX<PXOA: PXOOutRep, PXOB: PXOOutRep>: PXInAB, PXOOutRep {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPxA: PXOA
    public let inPxB: PXOB

    let blendMode: RenderKit.BlendMode

    public init(blendMode: RenderKit.BlendMode, leading inPxA: () -> (PXOA), trailing inPxB: () -> (PXOB)) {
        print("PX Blend Init")
        self.inPxA = inPxA()
        self.inPxB = inPxB()
        self.blendMode = blendMode
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Blend Make")
        let objectEffect: PXObjectMergerEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
        var connectedA: Bool = false
        let hostA = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxA, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
            guard let connectObjectA = connectObject else { return }
            guard !connectedA else { return }
            self.connectA(from: connectObjectA, to: objectEffect)
            connectedA = true
        })))
        pixView.addSubview(hostA.view)
        
        var connectedB: Bool = false
        let hostB = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxB, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
            guard let connectObjectB = connectObject else { return }
            guard !connectedB else { return }
            self.connectB(from: connectObjectB, to: objectEffect)
            connectedB = true
        })))
        pixView.addSubview(hostB.view)
        
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
        if let inputObject: PXObject = objectEffect.inputObjectA {
            inPxA.animate(object: inputObject, transaction: transaction)
        }
        if let inputObject: PXObject = objectEffect.inputObjectB {
            inPxB.animate(object: inputObject, transaction: transaction)
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

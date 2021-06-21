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
public final class StackPX<PXO: PXOOutRep>: PXIns, PXOOutRep {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPxs: [PXO]

    let padding: CGFloat
    let spacing: CGFloat

    public init(padding: CGFloat, spacing: CGFloat, @PXBuilder inPxs: () -> [PXO]) {
        print("PX Stack Init")
        self.padding = padding
        self.spacing = spacing
        self.inPxs = inPxs()
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Stack Make")
        let objectEffect: PXObjectEffect = context.coordinator
//        setup(object: objectEffect)
        let pixView: PIXView = objectEffect.pix.pixView
        var connected: Bool = false
        for (index, inPx) in inPxs.enumerated() {
            let host = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPx, object: Binding<PXObject?>(get: { nil }, set: { connectObject in
                guard let connectObject = connectObject else { return }
                guard !connected else { return }
                self.connect(from: connectObject, to: objectEffect, at: index)
                connected = true
            })))
            pixView.addSubview(host.view)
        }
        pxObjectExtractor.object = objectEffect
        return pixView
    }

//    func setup(object: PXObjectEffect<PXO>) {
//        object.update = { transaction, px in
//            self.animate(object: object, transaction: transaction)
//        }
//    }
    
    public func animate(object: PXObject, transaction: Transaction) {
        
        let pix: StackPIX = object.pix as! StackPIX
        
        if !transaction.disablesAnimations,
           let animation: Animation = transaction.animation {
            print("PX Stack Animate")
            PXHelper.animate(animation: animation, timer: &object.timer) { padding in
                PXHelper.motion(pxKeyPath: \.padding, pixKeyPath: \.padding, px: self, pix: pix, at: self.padding)
                PXHelper.motion(pxKeyPath: \.spacing, pixKeyPath: \.spacing, px: self, pix: pix, at: self.spacing)
            }
        } else {
            print("PX Stack Animate Direct")
            pix.padding = padding
            pix.spacing = spacing
        }
        
        let objectEffect: PXObjectEffect = object as! PXObjectEffect
        if let inputObject: PXObject = objectEffect.inputObject {
            for inPx in inPxs {
                inPx.animate(object: inputObject, transaction: transaction)
            }
        }
    }

    public func connect(from connectObject: PXObject,
                        to objectEffect: PXObjectEffect,
                        at index: Int) {
        objectEffect.inputObject = connectObject
        let pix: StackPIX = objectEffect.pix as! StackPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            if !pix.inputs.indices.contains(index) || pix.inputs[index].id != inPix.id {
                pix.inputs.insert(inPix, at: index)
                print("PX Stack Connected at index \(index)!")
            }
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Stack Update")
        let object: PXObjectEffect = context.coordinator
//        object.update?(context.transaction, self)
//        object.inputObject?.update?(context.transaction, inPx)
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObjectEffect {
        PXObjectEffect(pix: StackPIX())
    }
}

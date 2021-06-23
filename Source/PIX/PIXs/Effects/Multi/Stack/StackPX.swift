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

public final class StackPX<PV: PXView>: PXIns, PXView  {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    public let inPxs: [PV]

    let padding: CGFloat
    let spacing: CGFloat

    public init(padding: CGFloat, spacing: CGFloat, @PXBuilder inPxs: () -> [PV]) {
        print("PX Stack Init")
        self.padding = padding
        self.spacing = spacing
        self.inPxs = inPxs()
    }
    
    public func makeView(context: Context) -> PIXView {
        print("PX Stack Make")
        let objectEffect: PXObjectMultiEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
        var connected: [Bool] = [Bool].init(repeating: false, count: 2)
        func bind(index: Int, done: @escaping () -> ()) {
            let objectBinding = Binding<PXObject?>(get: { nil }, set: { connectObject in
                guard let connectObject = connectObject else { return }
                guard !connected[index] else { return }
                self.appendConnect(from: connectObject, to: objectEffect)
                connected[index] = true
                DispatchQueue.main.async {
                    done()
                }
            })
            guard let view = UINSHostingView(rootView: PXObjectExtractorView(content: inPxs[index], object: objectBinding)).view else { return }
            pixView.addSubview(view)
        }
        
        var currentIndex = 0
        func next() {
            if currentIndex < inPxs.count {
                bind(index: currentIndex) {
                    currentIndex += 1
                    next()
                }
            }
        }
        next()
        
        pxObjectExtractor.object = objectEffect
        return pixView
    }
    
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
        
        let objectEffect: PXObjectMultiEffect = object as! PXObjectMultiEffect
        for (index, inputObject) in objectEffect.inputObjects.enumerated() {
            inPxs[index].animate(object: inputObject, transaction: transaction)
        }
    }

    public func appendConnect(from connectObject: PXObject,
                              to objectEffect: PXObjectMultiEffect) {
        objectEffect.inputObjects.append(connectObject)
        let pix: StackPIX = objectEffect.pix as! StackPIX
        if let inPix: PIX & NODEOut = connectObject.pix as? PIX & NODEOut {
            pix.inputs.insert(inPix, at: pix.inputs.count)
            print("PX Blend Connected N!")
        }
    }

    public func updateView(_ uiView: PIXView, context: Context) {
        print("PX Stack Update")
        let object: PXObjectMultiEffect = context.coordinator
        animate(object: object, transaction: context.transaction)
    }
    
    public func makeCoordinator() -> PXObjectMultiEffect {
        PXObjectMultiEffect(pix: StackPIX(at: .square(1000)))
    }
}

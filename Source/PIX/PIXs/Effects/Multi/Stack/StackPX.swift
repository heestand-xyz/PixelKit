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

public final class StackPX<PXO: PXOOutRep>: PXIns, PXOOutRep  {
    
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
        let objectEffect: PXObjectMultiEffect = context.coordinator
        let pixView: PIXView = objectEffect.pix.pixView
        
//        var count: Int = 0
//        if inPxs.9 != nil {
//            count = 10
//        } else if inPxs.8 != nil {
//            count = 9
//        } else if inPxs.7 != nil {
//            count = 8
//        } else if inPxs.6 != nil {
//            count = 7
//        } else if inPxs.5 != nil {
//            count = 6
//        } else if inPxs.4 != nil {
//            count = 5
//        } else if inPxs.3 != nil {
//            count = 4
//        } else if inPxs.2 != nil {
//            count = 3
//        } else if inPxs.1 != nil {
//            count = 2
//        } else if inPxs.0 != nil {
//            count = 1
//        }

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
            let view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs[index], object: objectBinding)).view
//            var view: UINSView!
//            switch index {
//            case 0: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.0!, object: objectBinding)).view
//            case 1: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.1!, object: objectBinding)).view
//            case 2: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.2!, object: objectBinding)).view
//            case 3: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.3!, object: objectBinding)).view
//            case 4: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.4!, object: objectBinding)).view
//            case 5: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.5!, object: objectBinding)).view
//            case 6: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.6!, object: objectBinding)).view
//            case 7: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.7!, object: objectBinding)).view
//            case 8: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.8!, object: objectBinding)).view
//            case 9: view = UINSHostingView(rootView: PXObjectExtractorView(pxo: inPxs.9!, object: objectBinding)).view
//            default:
//                break
//            }
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
        
//        if count > 0 {
//            bind(index: 0) {
//                if count > 1 {
//                    bind(index: 1) {
//                        if count > 2 {
//                            bind(index: 2) {
//                                if count > 3 {
//                                    bind(index: 3) {
//                                        if count > 4 {
//                                            bind(index: 4) {
//                                                if count > 5 {
//                                                    bind(index: 5) {
//                                                        if count > 6 {
//                                                            bind(index: 6) {
//                                                                if count > 7 {
//                                                                    bind(index: 7) {
//                                                                        if count > 8 {
//                                                                            bind(index: 8) {
//                                                                                if count > 9 {
//                                                                                    bind(index: 9) {}
//                                                                                }
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                }
//                                                            }
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }

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
//            switch index {
//            case 0: inPxs.0?.animate(object: inputObject, transaction: transaction)
//            case 1: inPxs.1?.animate(object: inputObject, transaction: transaction)
//            case 2: inPxs.2?.animate(object: inputObject, transaction: transaction)
//            case 3: inPxs.3?.animate(object: inputObject, transaction: transaction)
//            case 4: inPxs.4?.animate(object: inputObject, transaction: transaction)
//            case 5: inPxs.5?.animate(object: inputObject, transaction: transaction)
//            case 6: inPxs.6?.animate(object: inputObject, transaction: transaction)
//            case 7: inPxs.7?.animate(object: inputObject, transaction: transaction)
//            case 8: inPxs.8?.animate(object: inputObject, transaction: transaction)
//            case 9: inPxs.9?.animate(object: inputObject, transaction: transaction)
//            default:
//                break
//            }
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

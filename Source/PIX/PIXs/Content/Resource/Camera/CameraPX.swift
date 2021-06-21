////
////  File.swift
////  
////
////  Created by Anton Heestand on 2021-06-09.
////
//
//import SwiftUI
//import RenderKit
//import PixelColor
//
//@available(iOS 14.0, *)
//public struct CameraPX: PXOut, PXOOutRep {
//    
//    public var object: PXObject {
//        let slug: String = String(describing: Mirror(reflecting: self))
//        print("PX Cicle Slug", slug)
//        return PXStore.store[slug] ?? {
//            let pix = CameraPIX()
//            print("PX Camera New....................", slug)
//            let object = PXObject(pix: pix)
//            PXStore.store[slug] = object
//            return object
//        }()
//    }
//    
//    public init() {
//        print("PX Camera Init")
//    }
//    
//    public func makeView(context: Context) -> PIXView {
//        print("PX Camera Make")
//        setup()
//        return object.pix.pixView
//    }
//    
//    func setup() {
//        object.update = { transaction, px in }
//    }
//
//    public func updateView(_ pixView: PIXView, context: Context) {
//        print("PX Camera Update")
//        object.update?(context.transaction, self)
//    }
//}

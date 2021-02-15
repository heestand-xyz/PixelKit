////
////  Created by Anton Heestand on 2021-02-04.
////
//
//import SwiftUI
//import RenderKit
//import PixelColor
//
//@available(iOS 14.0, *)
//public struct CirclePX: PXOut {
//    
//    public var object: PXObject = PXObject(pix: CirclePIX())
////    @State var pix = { () -> PIX in
////        print("PolygonPIX <----")
////        return PolygonPIX()
////    }()
//    public func getPix() -> PIX {
//        object.pix
//    }
//    
//    let radius: CGFloat
//    @State var position: CGPoint = .zero
//    @State var edgeRadius: CGFloat = 0.0
//    @State var edgeColor: PixelColor = .gray
//    
//    let resolution: Resolution
//
//    public init(radius: CGFloat = 0.25, resolution: Resolution = .auto(render: PixelKit.main.render)) {
//        print(".: Circle Init")
//        self.resolution = resolution
//        self.radius = radius
//    }
//    
//    public func makeUIView(context: Context) -> PIXView {
//        print(".: Circle Make")
//        return object.pix.pixView
//    }
//    
//    public static func dismantleUIView(_ uiView: PIXView, coordinator: Coordinator) {
//        print(".: Circle Dismantle")
//    }
//    
//    public func updateUIView(_ uiView: PIXView, context: Context) {
//        let circlePix: CirclePIX = object.pix as! CirclePIX
//        if !context.transaction.disablesAnimations,
//           let animation: Animation = context.transaction.animation {
//            print(".: Circle Update Animation")
//            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
//                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: circlePix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: circlePix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.edgeRadius, pixKeyPath: \.edgeRadius, px: self, pix: circlePix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.edgeColor, pixKeyPath: \.edgeColor, px: self, pix: circlePix, at: fraction)
//            }
//        } else {
//            print(".: Circle Update")
//            circlePix.radius = radius
//            circlePix.position = position
//            circlePix.edgeRadius = edgeRadius
//            circlePix.edgeColor = edgeColor
//        }
//        if circlePix.resolution != resolution {
//            circlePix.resolution = resolution
//        }
//    }
//    
//    // MARK: - Coordinator
//    
//    public func makeCoordinator() -> Coordinator {
//        print(".: Circle Coordinator")
//        return Coordinator()
//    }
//    
//    public class Coordinator {
//        public var timer: Timer?
////        public var pix: PIX = CirclePIX()
////        init(pix: CirclePIX) {
////            self.pix = pix
////        }
//    }
//    
//    // MARK: - Property Funcs
//    
//    public func pxCirclePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CirclePX {
//        position = CGPoint(x: x, y: y)
//        return self
//    }
//
//    public func pxCircleEdgeRadius(_ value: CGFloat) -> CirclePX {
//        edgeRadius = value
//        return self
//    }
//
//    public func pxCircleEdgeColor(_ value: PixelColor) -> CirclePX {
//        edgeColor = value
//        return self
//    }
//    
//}

////
////  Created by Anton Heestand on 2021-02-04.
////
//
//import Foundation
//import SwiftUI
//import RenderKit
//import PixelColor
//
//@available(iOS 14.0, *)
//public struct BlurPX<PXO: PXOut>: PXIn, PXOut {
//    
//    public var object: PXObject = PXObject(pix: BlurPIX())
//    
//    public func getPix() -> PIX {
//        object.pix
//    }
//    
//    var inPx: () -> (PXO)
//    
//    let radius: CGFloat
//    @State var style: BlurPIX.BlurStyle = .regular
//    @State var quality: PIX.SampleQualityMode = .mid
//    @State var angle: CGFloat = 0.0
//    @State var position: CGPoint = .zero
//    
//    init(radius: CGFloat, inPx: @escaping () -> (PXO)) {
//        print(".: Blur Init")
//        self.radius = radius
//        self.inPx = inPx
//    }
//    
//    public func makeUIView(context: Context) -> PIXView {
//        print(".: Blur Make")
//        
//        let px: PXO = inPx()
//
//        let pixView: PIXView = object.pix.pixView
//        
////        let hostingController = UINSHostingView(rootView: ZStack { px })
////        let inPxView: UINSView = hostingController.view
////        inPxView.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
////        pixView.addSubview(inPxView)
//        
//        let blurPix: BlurPIX = object.pix as! BlurPIX
//        if let inPix: PIX & NODEOut = px.getPix() as? PIX & NODEOut {
//            if blurPix.input?.id != inPix.id {
//                print(".: Blur Make Connect!")
//                blurPix.input = inPix
//            }
//        }
//        
//        return pixView
//    }
//    
//    public static func dismantleUIView(_ uiView: PIXView, coordinator: Coordinator) {
//        print(".: Blur Dismantle")
//    }
//    
//    public func updateUIView(_ uiView: PIXView, context: Context) {
//        let blurPix: BlurPIX = object.pix as! BlurPIX
//        if !context.transaction.disablesAnimations,
//           let animation: Animation = context.transaction.animation {
//            print(".: Blur Update Animation", radius)
//            blurPix.style = style
//            blurPix.quality = quality
//            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
//                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: blurPix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.angle, pixKeyPath: \.angle, px: self, pix: blurPix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: blurPix, at: fraction)
//            }
//        } else {
//            print(".: Blur Update Direct")
//            blurPix.style = style
//            blurPix.radius = radius
//            blurPix.quality = quality
//            blurPix.angle = angle
//            blurPix.position = position
//        }
//    }
//    
//    // MARK: - Coordinator
//    
//    public func makeCoordinator() -> Coordinator {
//        print(".: Blur Coordinator")
//        return Coordinator()
//    }
//    
//    public class Coordinator {
//        public var timer: Timer?
////        public var pix: PIX = BlurPIX()
////        init(pix: BlurPIX) {
////            self.pix = pix
////        }
//    }
//    
//    // MARK: - Property Funcs
//    
//    public func pxBlurStyle(_ style: BlurPIX.BlurStyle) -> BlurPX {
//        self.style = style
//        return self
//    }
//
//    public func pxBlurQuality(_ quality: PIX.SampleQualityMode) -> BlurPX {
//        self.quality = quality
//        return self
//    }
//
//    public func pxBlurAngle(_ angle: CGFloat) -> BlurPX {
//        self.angle = angle
//        return self
//    }
//
//    public func pxBlurPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> BlurPX {
//        position = CGPoint(x: x, y: y)
//        return self
//    }
//    
//}
//
//@available(iOS 14.0, *)
//public extension PXOut {
//        
//    func pxBlur(radius: CGFloat) -> BlurPX<Self> {
//        print(".: Blur Func")
//        return BlurPX(radius: radius, inPx: { self })
//    }
//    
////    func pxZoomBlur(radius: CGFloat) -> BlurPX {
////        let px = BlurPX(inPx: { self })
////        px.style = .zoom
////        px.quality = .epic
////        px.radius = radius
////        return px
////    }
//    
//}
//

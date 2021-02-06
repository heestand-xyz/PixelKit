////
////  Created by Anton Heestand on 2021-02-04.
////
//
//import Foundation
//import SwiftUI
//import RenderKit
//import PixelColor
//
////public struct BlurX: View {
////    public var body: some View {
////        BlurPIX()
////    }
////}
//
//@available(iOS 14.0, *)
//public struct BlurPX<PXO: PXOut>: PXIn, PXOut, UINSViewRepresentable {
//
////    @State public var coordinator: PXCoordinator = Coordinator()
////    @State public var pixId: UUID?
//
//    @StateObject public var host: PXHost = PXHost(pix: BlurPIX())
//
//    public func getPix() -> PIX {
//        host.pix
//    }
//
////    let inPix: () -> (PIX)
//
//    var inPx: () -> (PXO)
//
//    @State var radius: CGFloat = 0.5
//    @State var style: BlurPIX.BlurStyle = .regular
//    @State var quality: PIX.SampleQualityMode = .mid
//    @State var angle: CGFloat = 0.0
//    @State var position: CGPoint = .zero
//
//    init(inPx: @escaping () -> (PXO)) {
//        print(".: Blur Init")
//        self.inPx = inPx
////        let pix = BlurPIX()
////        pixId = pix.id
////        PXHub.shared.add(pix: pix)
//    }
//
//    public func makeUIView(context: Context) -> PIXView {
//        print(".: Blur Make")
//
//        let px: PXO = inPx()
//
//        let pixView: PIXView = host.pix.pixView
//
////        let hostingController = UINSHostingView(rootView: ZStack { px })
////        let inPxView: UINSView = hostingController.view
////        inPxView.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
////        pixView.addSubview(inPxView)
//
////        let blurPix: BlurPIX = host.pix as! BlurPIX
////        if let inPix: PIX & NODEOut = px.getPix() as? PIX & NODEOut {
////            if blurPix.input?.id != inPix.id {
////                print(".: Blur Make Connect!")
////                blurPix.input = inPix
////            }
////        }
//
//        return pixView
//    }
//
//    public static func dismantleUIView(_ uiView: PIXView, coordinator: Coordinator) {
//        print(".: Blur Dismantle")
//    }
//
//    public func updateUIView(_ uiView: PIXView, context: Context) {
//        let blurPix: BlurPIX = host.pix as! BlurPIX
//        if !context.transaction.disablesAnimations,
//           let animation: Animation = context.transaction.animation {
//            print(".: Blur Update Animation")
//            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
//                PXHelper.motion(pxKeyPath: \.style, pixKeyPath: \.style, px: self, pix: blurPix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: blurPix, at: fraction)
//                PXHelper.motion(pxKeyPath: \.quality, pixKeyPath: \.quality, px: self, pix: blurPix, at: fraction)
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
////        if let pixOut: PIX & NODEOut = PXConnector.shared.fetch(pxIn: self) {
////            print("Blur Update Connect")
////            blurPix.input = pixOut
////        }
////        PXConnector.shared.check(pxOut: self, pixOut: blurPix)
//    }
//
//    // MARK: - Coordinator
//
//    public func makeCoordinator() -> Coordinator {
//        print(".: Blur Coordinator")
////        let id: UUID = pixId!
////        let pix: BlurPIX = PXHub.shared.pix(id: id) as! BlurPIX
////        let coordinator = Coordinator(pix: pix)
////        return coordinator
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
//        let px = BlurPX(inPx: { self })
//        px.radius = radius
//        return px
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

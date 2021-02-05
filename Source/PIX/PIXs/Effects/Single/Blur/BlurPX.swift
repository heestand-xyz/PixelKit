//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import SwiftUI
import RenderKit
import PixelColor

public struct BlurPX: PXIn, PXOut, UINSViewRepresentable {
        
    @State public var id: UUID?

//    @State public var pix: PIX = BlurPIX()
//    public var pixOut: PIX & NODEOut { pix as! PIX & NODEOut }
//    var blurPix: BlurPIX { pix as! BlurPIX }
    
//    @State public var pixId: UUID?
//    var pix: PIX? {
//        PixelKit.main.render.linkedNodes.first(where: { $0.id == pixId }) as? PIX
//    }

//    let inPixId: () -> (UUID)
//    var inPix: (PIX & NODEOut)? {
//        PixelKit.main.render.linkedNodes.first(where: { $0.id == inPixId() }) as? PIX & NODEOut
//    }
    let inPx: PXOut

    @State var radius: CGFloat = 0.5

    @State var style: BlurPIX.BlurStyle = .regular
    @State var quality: PIX.SampleQualityMode = .mid
    @State var angle: CGFloat = 0.0
    @State var position: CGPoint = .zero
    
    init(inPx: PXOut) {
        print(".: Blur Init")
        self.inPx = inPx
        
//        PXConnector.shared.add(inPx, to: self)
    }
    
    public func makeUIView(context: Context) -> PIXView {
        print(".: Blur Make")
//        id = UUID()
        return context.coordinator.pix.pixView
    }
    
    public func updateUIView(_ uiView: PIXView, context: Context) {
        print(".: Blur Update")
        let blurPix: BlurPIX = context.coordinator.pix
//        if blurPix.input?.id != inPix?.id {
//            print("PX Connect!")
//            blurPix.input = inPix
//        }
        if !context.transaction.disablesAnimations,
           let animation: Animation = context.transaction.animation {
            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.style, pixKeyPath: \.style, px: self, pix: blurPix, at: fraction)
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: blurPix, at: fraction)
                PXHelper.motion(pxKeyPath: \.quality, pixKeyPath: \.quality, px: self, pix: blurPix, at: fraction)
                PXHelper.motion(pxKeyPath: \.angle, pixKeyPath: \.angle, px: self, pix: blurPix, at: fraction)
                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: blurPix, at: fraction)
            }
        } else {
            blurPix.style = style
            blurPix.radius = radius
            blurPix.quality = quality
            blurPix.angle = angle
            blurPix.position = position
        }
//        if let pixOut: PIX & NODEOut = PXConnector.shared.fetch(pxIn: self) {
//            print("Blur Update Connect")
//            blurPix.input = pixOut
//        }
//        PXConnector.shared.check(pxOut: self, pixOut: blurPix)
    }
    
    // MARK: - Coordinator
    
    public func makeCoordinator() -> Coordinator {
        print(".: Blur Coordinator")
        let coordinator = Coordinator()
        return coordinator
    }
    
    public class Coordinator {
        var timer: Timer?
        var pix: BlurPIX = .init()
    }
    
    // MARK: - Property Funcs
    
    public func pxBlurStyle(_ style: BlurPIX.BlurStyle) -> BlurPX {
        self.style = style
        return self
    }

    public func pxBlurQuality(_ quality: PIX.SampleQualityMode) -> BlurPX {
        self.quality = quality
        return self
    }

    public func pxBlurAngle(_ angle: CGFloat) -> BlurPX {
        self.angle = angle
        return self
    }

    public func pxBlurPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> BlurPX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
}

public extension PXOut {
    
    func pxBlur(radius: CGFloat) -> BlurPX {
        print(".: Blur Func")
        let px = BlurPX(inPx: self)
        px.radius = radius
        return px
    }
    
    func pxZoomBlur(radius: CGFloat) -> BlurPX {
        let px = BlurPX(inPx: self)
        px.style = .zoom
        px.quality = .epic
        px.radius = radius
        return px
    }
    
}


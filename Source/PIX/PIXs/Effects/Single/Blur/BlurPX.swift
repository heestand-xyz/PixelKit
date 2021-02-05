//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

public struct BlurPX: PXIn, PXOut, UINSViewRepresentable {
    
    @State public var pixId: UUID?
//    @StateObject var pix: BlurPIX = BlurPIX()
    
    @State var inPx: PXOut?
    
    @State var style: BlurPIX.BlurStyle = .regular
    @State var radius: CGFloat = 0.5
    @State var quality: PIX.SampleQualityMode = .mid
    @State var angle: CGFloat = 0.0
    @State var position: CGPoint = .zero
    
    public func makeUIView(context: Context) -> PIXView {
        context.coordinator.pix.pixView
    }
    
    public func updateUIView(_ uiView: PIXView, context: Context) {
        if let px: PX = inPx {
            if let inPix: PIX & NODEOut = PixelKit.main.render.linkedNodes.first(where: { $0.id == px.pixId }) as? PIX & NODEOut {
                if context.coordinator.pix.input?.id != inPix.id {
                    print("PX Connect!")
                    context.coordinator.pix.input = inPix
                }
            }
        } else if context.coordinator.pix.input != nil {
            context.coordinator.pix.input = nil
        }
        if !context.transaction.disablesAnimations,
           let animation: Animation = context.transaction.animation {
            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.style, pixKeyPath: \.style, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.quality, pixKeyPath: \.quality, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.angle, pixKeyPath: \.angle, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: context.coordinator.pix, at: fraction)
            }
        } else {
            context.coordinator.pix.style = style
            context.coordinator.pix.radius = radius
            context.coordinator.pix.quality = quality
            context.coordinator.pix.angle = angle
            context.coordinator.pix.position = position
        }
    }
    
    // MARK: - Coordinator
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        pixId = coordinator.pix.id
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
        let px = BlurPX()
        px.inPx = self
        px.radius = radius
        return px
    }
    
    func pxZoomBlur(radius: CGFloat) -> BlurPX {
        let px = BlurPX()
        px.inPx = self
        px.style = .zoom
        px.quality = .epic
        px.radius = radius
        return px
    }
    
}


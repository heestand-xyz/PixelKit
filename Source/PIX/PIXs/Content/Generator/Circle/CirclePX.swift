//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

public struct CirclePX: PXOut, UINSViewRepresentable {
    
    @State public var pixId: UUID?
    
    let radius: CGFloat
    @State var position: CGPoint = .zero
    @State var edgeRadius: CGFloat = 0.0
    @State var edgeColor: PixelColor = .gray

    public init(radius: CGFloat = 0.25) {
        self.radius = radius
    }
    
    public func makeUIView(context: Context) -> PIXView {
        context.coordinator.pix.pixView
    }
    
    public func updateUIView(_ uiView: PIXView, context: Context) {
        if !context.transaction.disablesAnimations,
           let animation: Animation = context.transaction.animation {
            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.edgeRadius, pixKeyPath: \.edgeRadius, px: self, pix: context.coordinator.pix, at: fraction)
                PXHelper.motion(pxKeyPath: \.edgeColor, pixKeyPath: \.edgeColor, px: self, pix: context.coordinator.pix, at: fraction)
            }
        } else {
            context.coordinator.pix.radius = radius
            context.coordinator.pix.position = position
            context.coordinator.pix.edgeRadius = edgeRadius
            context.coordinator.pix.edgeColor = edgeColor
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
        var pix: CirclePIX = .init()
    }
    
    // MARK: - Property Funcs
    
    public func pxCirclePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CirclePX {
        position = CGPoint(x: x, y: y)
        return self
    }

    public func pxCircleEdgeRadius(_ value: CGFloat) -> CirclePX {
        edgeRadius = value
        return self
    }

    public func pxCircleEdgeColor(_ value: PixelColor) -> CirclePX {
        edgeColor = value
        return self
    }
    
}

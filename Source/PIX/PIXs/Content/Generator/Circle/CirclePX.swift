//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit
import PixelColor

public struct CirclePX: PXOut, UINSViewRepresentable {
        
    @State public var id: UUID?
    
//    @State public var pix: PIX = CirclePIX()
//    public var pixOut: PIX & NODEOut { pix as! PIX & NODEOut }
//    var circlePix: CirclePIX { pix as! CirclePIX }
    
//    @State public var pixId: UUID?
//    var pix: PIX? {
//        PixelKit.main.render.linkedNodes.first(where: { $0.id == pixId }) as? PIX
//    }
    
    let radius: CGFloat
    @State var position: CGPoint = .zero
    @State var edgeRadius: CGFloat = 0.0
    @State var edgeColor: PixelColor = .gray
    
    let resolution: Resolution

    public init(radius: CGFloat = 0.25, resolution: Resolution = .auto(render: PixelKit.main.render)) {
        print(".: Circle Init")
        self.resolution = resolution
        self.radius = radius
    }
    
    public func makeUIView(context: Context) -> PIXView {
        print(".: Circle Make")
        return context.coordinator.pix.pixView
    }
    
    public func updateUIView(_ uiView: PIXView, context: Context) {
        print(".: Circle Update")
        let circlePix: CirclePIX = context.coordinator.pix
        if !context.transaction.disablesAnimations,
           let animation: Animation = context.transaction.animation {
            PXHelper.animate(animation: animation, timer: &context.coordinator.timer) { fraction in
                PXHelper.motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: circlePix, at: fraction)
                PXHelper.motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: circlePix, at: fraction)
                PXHelper.motion(pxKeyPath: \.edgeRadius, pixKeyPath: \.edgeRadius, px: self, pix: circlePix, at: fraction)
                PXHelper.motion(pxKeyPath: \.edgeColor, pixKeyPath: \.edgeColor, px: self, pix: circlePix, at: fraction)
            }
        } else {
            circlePix.radius = radius
            circlePix.position = position
            circlePix.edgeRadius = edgeRadius
            circlePix.edgeColor = edgeColor
        }
        if circlePix.resolution != resolution {
            circlePix.resolution = resolution
        }
//        PXConnector.shared.check(pxOut: self, pixOut: circlePix)
    }
    
    // MARK: - Coordinator
    
    public func makeCoordinator() -> Coordinator {
        print(".: Circle Coordinator")
        let coordinator = Coordinator()
//        id = UUID()
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

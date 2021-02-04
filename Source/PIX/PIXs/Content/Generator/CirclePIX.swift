//
//  CirclePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import PixelColor
import SwiftUI

@available(iOS 14.0, *)
final public class CirclePX: PX, UINSViewRepresentable {
    
    typealias ThePIX = CirclePIX
    
    let radius: CGFloat
    var position: CGPoint = .zero
    var edgeRadius: CGFloat = 0.0
    var edgeColor: PixelColor = .gray

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
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        position = coordinator.pix.position
        edgeRadius = coordinator.pix.edgeRadius
        edgeColor = coordinator.pix.edgeColor
        return coordinator
    }
    
    public class Coordinator {
        var timer: Timer?
        var pix: ThePIX = .init()
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

final public class CirclePIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    @Live public var radius: CGFloat = 0.25
    @Live public var position: CGPoint = .zero
    @Live public var edgeRadius: CGFloat = 0.0
    @Live public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_radius, _position, _edgeRadius, _edgeColor]
    }
    override public var values: [Floatable] {
        return [radius, position, edgeRadius, super.color, edgeColor, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Circle", typeName: "pix-content-generator-circle")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            radius: CGFloat = 0.25) {
        self.init(at: resolution)
        self.radius = radius
    }
    
    // MARK: - Property Funcs
    
    public func pixCirclePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CirclePIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixCircleEdgeRadius(_ value: CGFloat) -> CirclePIX {
        edgeRadius = value
        return self
    }
    
    public func pixCircleEdgeColor(_ value: PixelColor) -> CirclePIX {
        edgeColor = value
        return self
    }
    
}

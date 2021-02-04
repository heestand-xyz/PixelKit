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

func animate(animation: Animation, timer: inout Timer?, loop: @escaping (CGFloat) -> ()) {
    let duration: Double = extract("duration", in: animation.description) ?? 0.0
    let bx: Double = extract("bx", in: animation.description) ?? 1.0
    let startTime: Date = .init()
    let interval: Double = 1.0 / Double(PixelKit.main.render.fpsMax)
    timer?.invalidate()
    enum Ease {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    var ease: Ease = .linear
    if bx == 3.0 {
        ease = .linear
    } else if bx < 0.0 {
        ease = .easeInOut
    } else if bx < 1.0 {
        ease = .easeIn
    } else if bx > 1.0 {
        ease = .easeOut
    }
    timer = Timer(timeInterval: interval, repeats: true) { timer in
        let rawFraction: CGFloat = CGFloat(-startTime.timeIntervalSinceNow / duration)
        var fraction: CGFloat = rawFraction
        if animation == .easeIn(duration: 0.0) {
            print("Aa")
            fraction = cos(-.pi + fraction * .pi / 2)
        }
        switch ease {
        case .easeIn:
            fraction = cos(-.pi + fraction * .pi / 2) + 1.0
        case .easeOut:
            fraction = cos(-.pi / 2 + fraction * .pi / 2)
        case .easeInOut:
            fraction = cos(.pi + fraction * .pi) / 2.0 + 0.5
        case .linear:
            break
        }
        if fraction > 1.0 {
            fraction = 1.0
        }
        loop(fraction)
        if rawFraction >= 1.0 {
            timer.invalidate()
        }
    }
    RunLoop.current.add(timer!, forMode: .common)
    
}

func extract(_ name: String, in text: String) -> String? {
    if text.contains("\(name): ") {
        if let subText: String.SubSequence = text.components(separatedBy: "\(name): ").last?
            .split(separator: ")").first?
            .split(separator: ",").first {
            return String(subText)
        }
    }
    return nil
}
func extract(_ name: String, in text: String) -> Double? {
    if let valueText: String = extract(name, in: text) {
        if let value: Double = Double(valueText) {
            return value
        }
    }
    return nil
}

//func animate<F: Floatable, Pix: PIX, Px: PX>(px: Px,
//                                             pxKeyPath: KeyPath<Px, F>,
//                                             pix: Pix,
//                                             pixKeyPath: WritableKeyPath<Pix, F>,
//                                             transaction: Transaction,
//                                             timer: inout Timer?) {
//    let oldValue: F = pix[keyPath: pixKeyPath]
//    let newValue: F = px[keyPath: pxKeyPath]
//    guard newValue.floats != oldValue.floats else { return }
//    var pix: Pix = pix
//    if !transaction.disablesAnimations,
//       let animation: Animation = transaction.animation {
//        animate(animation: animation, timer: &timer) { fraction in
//            let floats: [CGFloat] = zip(oldValue.floats, newValue.floats)
//                .map { (current, new) in
//                    current * (1.0 - fraction) + new * fraction
//                }
//            let value: F = F(floats: floats)
//            pix[keyPath: pixKeyPath] = value
//        }
//    } else {
//        pix[keyPath: pixKeyPath] = px[keyPath: pxKeyPath]
//    }
//}

func motion<F: Floatable, Pix: PIX, Px: PX>(pxKeyPath: KeyPath<Px, F>,
                                            pixKeyPath: WritableKeyPath<Pix, F>,
                                            px: Px,
                                            pix: Pix,
                                            at fraction: CGFloat) {
    let oldValue: F = pix[keyPath: pixKeyPath]
    let newValue: F = px[keyPath: pxKeyPath]
    guard newValue.floats != oldValue.floats else { return }
    var pix: Pix = pix
    let floats: [CGFloat] = zip(oldValue.floats, newValue.floats)
        .map { (current, new) in
            current * (1.0 - fraction) + new * fraction
        }
    let value: F = F(floats: floats)
    pix[keyPath: pixKeyPath] = value
}


protocol PX {}

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
            animate(animation: animation, timer: &context.coordinator.timer) { fraction in
                motion(pxKeyPath: \.radius, pixKeyPath: \.radius, px: self, pix: context.coordinator.pix, at: fraction)
                motion(pxKeyPath: \.position, pixKeyPath: \.position, px: self, pix: context.coordinator.pix, at: fraction)
                motion(pxKeyPath: \.edgeRadius, pixKeyPath: \.edgeRadius, px: self, pix: context.coordinator.pix, at: fraction)
                motion(pxKeyPath: \.edgeColor, pixKeyPath: \.edgeColor, px: self, pix: context.coordinator.pix, at: fraction)
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

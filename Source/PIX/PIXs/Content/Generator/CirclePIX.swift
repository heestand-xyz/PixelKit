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
public struct CirclePX: UINSViewRepresentable {
    
    let radius: CGFloat
    let position: CGPoint = .zero
    let edgeRadius: CGFloat = 0.0
    let edgeColor: PixelColor = .gray
    
    public init(radius: CGFloat = 0.25) {
        self.radius = radius
    }
//    init(radius: CGFloat = 0.25,
//         position: CGPoint = .zero,
//         edgeRadius: CGFloat = 0.0,
//         edgeColor: PixelColor = .gray) {
//        self.radius = radius
//        self.position = position
//        self.edgeRadius = edgeRadius
//        self.edgeColor = edgeColor
//    }
//
//    public convenience init(radius: CGFloat = 0.25) {
//        self.init(radius: radius,
//                  position: .zero,
//                  edgeRadius: 0.0,
//                  edgeColor: .gray)
//    }
    
    public func makeUIView(context: Context) -> PIXView {
        context.coordinator.pix.radius = radius
        context.coordinator.pix.position = position
        context.coordinator.pix.edgeRadius = edgeRadius
        context.coordinator.pix.edgeColor = edgeColor
        return context.coordinator.pix.pixView
    }
    
    public func updateUIView(_ uiView: PIXView, context: Context) {
        if !context.transaction.disablesAnimations,
           let animation: Animation = context.transaction.animation {
            let duration: Double = extract("duration", in: animation.description) ?? 0.0
            let bx: Double = extract("bx", in: animation.description) ?? 1.0
            let oldValue = get(in: context)
            let newValue = radius
            print("Animate", "duration:", duration, "from:", oldValue, "to:", newValue, ":::", animation.description)
            let startTime: Date = .init()
            let interval: Double = 1.0 / Double(PixelKit.main.render.fpsMax)
            context.coordinator.timer?.invalidate()
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
            context.coordinator.timer = Timer(timeInterval: interval, repeats: true) { timer in
                let rawFraction: Double = -startTime.timeIntervalSinceNow / duration
                var fraction: Double = -startTime.timeIntervalSinceNow / duration
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
                let value: CGFloat = oldValue * CGFloat(1.0 - fraction) + newValue * CGFloat(fraction)
                self.set(radius: value, in: context)
                if rawFraction >= 1.0 {
                    timer.invalidate()
                }
            }
            RunLoop.current.add(context.coordinator.timer!, forMode: .common)
            
        } else {
            set(radius: radius, in: context)
        }
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
    
    func set(radius: CGFloat, in context: Context) {
        context.coordinator.pix.radius = radius
    }
    
    func get(in context: Context) -> CGFloat {
        context.coordinator.pix.radius
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator {
        var timer: Timer?
        let pix: CirclePIX = .init()
    }
    
    // MARK: - Property Funcs
    
//    public func pxCirclePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CirclePX {
//        CirclePX(radius: radius, position: CGPoint(x: x, y: y), edgeRadius: edgeRadius, edgeColor: edgeColor)
//    }
//
//    public func pxCircleEdgeRadius(_ value: CGFloat) -> CirclePX {
//        CirclePX(radius: radius, position: position, edgeRadius: value, edgeColor: edgeColor)
//    }
//
//    public func pxCircleEdgeColor(_ value: PixelColor) -> CirclePX {
//        CirclePX(radius: radius, position: position, edgeRadius: edgeRadius, edgeColor: value)
//    }
    
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

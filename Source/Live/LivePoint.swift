//
//  LivePoint.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-11-27.
//  Open Source - MIT License
//

#if os(macOS)
import AppKit
#endif
import CoreGraphics

public class LivePoint: LiveValue, CustomStringConvertible {
    
    public var name: String?
    
    public var x: LiveFloat
    public var y: LiveFloat
    
    public var description: String {
        let _x: CGFloat = round(CGFloat(x) * 1_000) / 1_000
        let _y: CGFloat = round(CGFloat(y) * 1_000) / 1_000
        return "live\(name != nil ? "[\(name!)]" : "")(x:\("\(_x)".zfill(3)),y:\("\(_y)".zfill(3)))"
    }
    
    public var size: LiveSize { return LiveSize(w: x, h: y) }
    
    // MARK: Uniform
    
    public var uniformIsNew: Bool {
        return x.uniformIsNew || y.uniformIsNew
    }
    
    public var uniformList: [CGFloat] {
        return [x.uniform, y.uniform]
    }
    
    public var cg: CGPoint {
        return CGPoint(x: x.cg, y: y.cg)
    }
    
    // MARK: Points
    
//    public static var circle: LiveColor {
//    }
    
    public static var zero: LivePoint { return LivePoint(x: 0.0, y: 0.0) }
    
    #if os(iOS)
    public static var touchXY: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                return pix.view.liveTouchView.touchPointMain
            }
            return .zero
        })
    }
//    public static var touchPoints: [LivePoint] {
//        var points: [LivePoint] = []
//        for i in 0..<10 {
//            let point = LivePoint({ () -> (CGPoint) in
//                for pix in PixelKit.main.linkedPixs {
//                    guard pix.view.superview != nil else { continue }
//                    let touchPoints = pix.view.liveTouchView.touchPoints
//                    guard touchPoints.count > i else { continue }
//                    return touchPoints[i]
//                }
//                return .zero
//            })
//            points.append(point)
//        }
//        return points
//    }
    #elseif os(macOS)
    public static var mouseXYAbs: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            return NSEvent.mouseLocation
        })
    }
    public static var mouseXY: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            for linkedPix in PixelKit.main.linkedPixs {
                guard linkedPix.view.superview != nil else { continue }
                if let mousePoint = linkedPix.view.liveMouseView.mousePoint {
                    return mousePoint
                }
            }
            return .zero
        })
    }
    #endif
    
    // MARK: Life Cycle
    
    public init(_ liveValue: @escaping () -> (CGPoint)) {
        x = LiveFloat({ return liveValue().x })
        y = LiveFloat({ return liveValue().y })
    }
    
    public init(x: LiveFloat, y: LiveFloat) {
        self.x = x
        self.y = y
    }
    
    public init(_ point: CGPoint) {
        x = LiveFloat(point.x)
        y = LiveFloat(point.y)
    }
    
    public init(name: String, point: CGPoint) {
        self.name = name
        x = LiveFloat(point.x)
        y = LiveFloat(point.y)
    }
    
    public init(_ vector: CGVector) {
        x = LiveFloat(vector.dx)
        y = LiveFloat(vector.dy)
    }
    
    public init(name: String, vector: CGVector) {
        self.name = name
        x = LiveFloat(vector.dx)
        y = LiveFloat(vector.dy)
    }
    
//    public init(xRel: LiveFloat, yRel: LiveFloat, res: PIX.Res) {
//        x = LiveFloat({ return CGFloat(xRel) / res.width })
//        y = LiveFloat({ return CGFloat(yRel) / res.width })
//    }
    
    // MARK: Flow Funcs
    
    public func delay(frames: LiveInt) -> LivePoint {
        return LivePoint(x: x.delay(frames: frames), y: y.delay(frames: frames))
    }
    
    public func delay(seconds: LiveFloat) -> LivePoint {
        return LivePoint(x: x.delay(seconds: seconds), y: y.delay(seconds: seconds))
    }
    
//    /// filter over frames.
//    public func filter(frames: LiveInt) -> LivePoint {
//        return LivePoint(x: x.filter(frames: frames), y: y.filter(frames: frames))
//    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true) -> LivePoint {
        return LivePoint(x: x.filter(seconds: seconds, smooth: smooth), y: y.filter(seconds: seconds, smooth: smooth))
    }
    
    public func liveCircle(seconds: LiveFloat = 1.0, scale: LiveFloat = 1.0) -> LivePoint {
        return LivePoint(x: cos(.live * seconds) * scale, y: sin(.live * seconds) * scale)
    }
    
    /// noise is a combo of liveRandom and smooth filter
    ///
    /// deafults - liveRandom range: -0.5...0.5 - filter seconds: 1.0
    public static func noise(xRange: ClosedRange<CGFloat> = -0.5...0.5,
                             yRange: ClosedRange<CGFloat> = -0.5...0.5,
                             seconds: LiveFloat = 1.0) -> LivePoint {
        return LivePoint(x: LiveFloat.noise(range: xRange, for: seconds),
                         y: LiveFloat.noise(range: yRange, for: seconds))
    }
    
    // MARK: Helpers
    
    public static func topLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: -res.aspect / 2.0, y: 0.5)
    }
    public static func topRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: res.aspect / 2.0, y: 0.5)
    }
    public static func bottomLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: -res.aspect / 2.0, y: -0.5)
    }
    public static func bottomRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: res.aspect / 2.0, y: -0.5)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LivePoint, rhs: LivePoint) -> LiveBool {
        return LiveBool({ return CGFloat(lhs.x) == CGFloat(rhs.x) && CGFloat(lhs.y) == CGFloat(rhs.y) })
    }
    public static func != (lhs: LivePoint, rhs: LivePoint) -> LiveBool {
        return !(lhs == rhs)
    }
    
    // MARK: Operators
    
    public static func + (lhs: LivePoint, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func + (lhs: LivePoint, rhs: LiveFloat) -> LivePoint {
        return LivePoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    public static func + (lhs: LiveFloat, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs + rhs.x, y: lhs + rhs.y)
    }
    public static func += (lhs: inout LivePoint, rhs: LivePoint) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x + rhs.x, y: _lhs.y + rhs.y)
    }
    public static func += (lhs: inout LivePoint, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x + rhs, y: _lhs.y + rhs)
    }
    
    public static func - (lhs: LivePoint, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    public static func - (lhs: LivePoint, rhs: LiveFloat) -> LivePoint {
        return LivePoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    public static func - (lhs: LiveFloat, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs - rhs.x, y: lhs - rhs.y)
    }
    public static func -= (lhs: inout LivePoint, rhs: LivePoint) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x - rhs.x, y: _lhs.y - rhs.y)
    }
    public static func -= (lhs: inout LivePoint, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x - rhs, y: _lhs.y - rhs)
    }
    
    public static func * (lhs: LivePoint, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    public static func * (lhs: LivePoint, rhs: LiveFloat) -> LivePoint {
        return LivePoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    public static func * (lhs: LiveFloat, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    public static func *= (lhs: inout LivePoint, rhs: LivePoint) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x * rhs.x, y: _lhs.y * rhs.y)
    }
    public static func *= (lhs: inout LivePoint, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x * rhs, y: _lhs.y * rhs)
    }
    
    public static func / (lhs: LivePoint, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    public static func / (lhs: LivePoint, rhs: LiveFloat) -> LivePoint {
        return LivePoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    public static func / (lhs: LiveFloat, rhs: LivePoint) -> LivePoint {
        return LivePoint(x: lhs / rhs.x, y: lhs / rhs.y)
    }
    public static func /= (lhs: inout LivePoint, rhs: LivePoint) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x / rhs.x, y: _lhs.y / rhs.y)
    }
    public static func /= (lhs: inout LivePoint, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LivePoint(x: _lhs.x / rhs, y: _lhs.y / rhs)
    }
    
    
    public func flipX() -> LivePoint {
        return LivePoint(x: -x, y: y)
    }
    public func flipY() -> LivePoint {
        return LivePoint(x: x, y: -y)
    }
    public func flipXY() -> LivePoint {
        return LivePoint(x: -x, y: -y)
    }
    public func flop() -> LivePoint {
        return LivePoint(x: y, y: x)
    }
    
}

public func atan(of point: LivePoint) -> LiveFloat {
    return LiveFloat({ return atan2(CGFloat(point.y), CGFloat(point.x)) })
}

public func pointFrom(angle: LiveFloat, radius: LiveFloat = 0.5) -> LivePoint {
    return LivePoint(x: cos(angle * .pi * 2) * radius, y: sin(angle * .pi * 2) * radius)
}

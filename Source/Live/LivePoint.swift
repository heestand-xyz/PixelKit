//
//  LivePoint.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-27.
//  Open Source - MIT License
//

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
    
    // MARK: Uniform
    
    var uniformIsNew: Bool {
        return x.uniformIsNew || y.uniformIsNew
    }
    
    var uniformList: [CGFloat] {
        return [x.uniform, y.uniform]
    }
    
    public var cg: CGPoint {
        return CGPoint(x: x.cg, y: y.cg)
    }
    
    // MARK: Points
    
//    public static var circle: LiveColor {
//    }
    
    public static var zero: LivePoint { return LivePoint(x: 0.0, y: 0.0) }
    
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
    
    /// filter over frames. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(frames: LiveInt, smooth: Bool = true) -> LivePoint {
        return LivePoint(x: x.filter(frames: frames, smooth: smooth), y: y.filter(frames: frames, smooth: smooth))
    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true) -> LivePoint {
        return LivePoint(x: x.filter(seconds: seconds, smooth: smooth), y: y.filter(seconds: seconds, smooth: smooth))
    }
    
    /// noise is a combo of liveRandom and smooth filter
    ///
    /// deafults - liveRandom range: -0.5...0.5 - filter seconds: 1.0
    public static func noise(xRange: ClosedRange<CGFloat> = -0.5...0.5,
                             yRange: ClosedRange<CGFloat> = -0.5...0.5,
                             seconds: LiveFloat = 1.0) -> LivePoint {
        return LivePoint(x: LiveFloat.noise(range: xRange, seconds: seconds),
                         y: LiveFloat.noise(range: yRange, seconds: seconds))
    }
    
    // MARK: Helpers
    
    public static func topLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(-res.aspect / 2.0), y: 0.5)
    }
    public static func topRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(res.aspect / 2.0), y: 0.5)
    }
    public static func bottomLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(-res.aspect / 2.0), y: -0.5)
    }
    public static func bottomRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(res.aspect / 2.0), y: -0.5)
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

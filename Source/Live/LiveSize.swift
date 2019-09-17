//
//  LiveSize.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-11-27.
//  Open Source - MIT License
//

import CoreGraphics

public class LiveSize: LiveValue, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var name: String?
    
    public var w: LiveFloat
    public var h: LiveFloat
    
    public var description: String {
        let _w: CGFloat = round(CGFloat(w) * 1_000) / 1_000
        let _h: CGFloat = round(CGFloat(h) * 1_000) / 1_000
        return "live\(name != nil ? "[\(name!)]" : "")(w:\("\(_w)".zfill(3)),h:\("\(_h)".zfill(3)))"
    }
    
    public var width: LiveFloat { return w }
    public var height: LiveFloat { return h }
    
    public var point: LivePoint { return LivePoint(x: w, y: h) }
    
    // MARK: Uniform
    
    public var uniformIsNew: Bool {
        return w.uniformIsNew || h.uniformIsNew
    }
    
    public var uniformList: [CGFloat] {
        return [w.uniform, h.uniform]
    }
    
    public var cg: CGSize {
        return CGSize(width: w.cg, height: h.cg)
    }
    
    // MARK: Static Sizes
    
    public static var one: LiveSize { return LiveSize(w: 1.0, h: 1.0) }
    public static var half: LiveSize { return LiveSize(w: 0.5, h: 0.5) }
    public static var quarter: LiveSize { return LiveSize(w: 0.25, h: 0.25) }
    public static var eighth: LiveSize { return LiveSize(w: 0.125, h: 0.125) }
    
    // MARK: Live Sizes
    
    public var flopped: LiveSize {
        return LiveSize(w: h, h: w)
    }

    // MARK: - Life Cycle
    
    public init(_ liveValue: @escaping () -> (CGSize)) {
        w = LiveFloat({ return liveValue().width })
        h = LiveFloat({ return liveValue().height })
    }
    
    public init(w: LiveFloat, h: LiveFloat) {
        self.w = w
        self.h = h
    }
    
    public init(width: LiveFloat, height: LiveFloat) {
        w = width
        h = height
    }
    
    public init(scale: LiveFloat) {
        w = scale
        h = scale
    }
    
    public init(_ size: CGSize) {
        w = LiveFloat(size.width)
        h = LiveFloat(size.height)
    }
        
    public init(name: String, size: CGSize) {
        self.name = name
        w = LiveFloat(size.width)
        h = LiveFloat(size.height)
    }
    
    required public init(floatLiteral value: FloatLiteralType) {
        w = LiveFloat(CGFloat(value))
        h = LiveFloat(CGFloat(value))
    }
    
    required public init(integerLiteral value: IntegerLiteralType) {
        w = LiveFloat(CGFloat(value))
        h = LiveFloat(CGFloat(value))
    }
    
//    public init(wRel: LiveFloat, hRel: LiveFloat, res: PIX.Res) {
//        w = LiveFloat({ return CGFloat(wRel) / res.width })
//        h = LiveFloat({ return CGFloat(hRel) / res.width })
//    }
    
    // MARK: Flow Funcs
    
    public func delay(frames: LiveInt) -> LiveSize {
        return LiveSize(w: w.delay(frames: frames), h: h.delay(frames: frames))
    }
    
    public func delay(seconds: LiveFloat) -> LiveSize {
        return LiveSize(w: w.delay(seconds: seconds), h: h.delay(seconds: seconds))
    }
    
//    /// filter over frames.
//    public func filter(frames: LiveInt, smooth: Bool = true) -> LiveSize {
//        return LiveSize(w: w.filter(frames: frames), h: h.filter(frames: frames))
//    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true) -> LiveSize {
        return LiveSize(w: w.filter(seconds: seconds, smooth: smooth), h: h.filter(seconds: seconds, smooth: smooth))
    }
    
    /// noise is a combo of liveRandom and smooth filter
    ///
    /// deafults - liveRandom range: 0.0...1.0 - filter seconds: 1.0
    public static func noise(wRange: ClosedRange<CGFloat> = 0.0...1.0,
                             hRange: ClosedRange<CGFloat> = 0.0...1.0,
                             seconds: LiveFloat = 1.0) -> LiveSize {
        return LiveSize(w: LiveFloat.noise(range: wRange, seconds: seconds),
                        h: LiveFloat.noise(range: hRange, seconds: seconds))
    }
    
    // MARK: Helpers
    
    public static func fill(aspect: LiveFloat) -> LiveSize {
        return LiveSize(w: aspect, h: 1.0)
    }
    
    public static func fill(res: PIX.Res) -> LiveSize {
        return LiveSize.fill(aspect: res.aspect)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveSize, rhs: LiveSize) -> LiveBool {
        return LiveBool({ return CGFloat(lhs.w) == CGFloat(rhs.w) && CGFloat(lhs.h) == CGFloat(rhs.h) })
    }
    public static func != (lhs: LiveSize, rhs: LiveSize) -> LiveBool {
        return !(lhs == rhs)
    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w + rhs.w, h: lhs.h + rhs.h)
    }
    public static func + (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w + rhs, h: lhs.h + rhs)
    }
    public static func + (lhs: LiveFloat, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs + rhs.w, h: lhs + rhs.h)
    }
    public static func += (lhs: inout LiveSize, rhs: LiveSize) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w + rhs.w, h: _lhs.h + rhs.h)
    }
    public static func += (lhs: inout LiveSize, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w + rhs, h: _lhs.h + rhs)
    }
    
    public static func - (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w - rhs.w, h: lhs.h - rhs.h)
    }
    public static func - (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w - rhs, h: lhs.h - rhs)
    }
    public static func - (lhs: LiveFloat, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs - rhs.w, h: lhs - rhs.h)
    }
    public static func -= (lhs: inout LiveSize, rhs: LiveSize) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w - rhs.w, h: _lhs.h - rhs.h)
    }
    public static func -= (lhs: inout LiveSize, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w - rhs, h: _lhs.h - rhs)
    }
    
    public static func * (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w * rhs.w, h: lhs.h * rhs.h)
    }
    public static func * (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w * rhs, h: lhs.h * rhs)
    }
    public static func * (lhs: LiveFloat, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs * rhs.w, h: lhs * rhs.h)
    }
    public static func *= (lhs: inout LiveSize, rhs: LiveSize) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w * rhs.w, h: _lhs.h * rhs.h)
    }
    public static func *= (lhs: inout LiveSize, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w * rhs, h: _lhs.h * rhs)
    }
    
    public static func / (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w / rhs.w, h: lhs.h / rhs.h)
    }
    public static func / (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w / rhs, h: lhs.h / rhs)
    }
    public static func / (lhs: LiveFloat, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs / rhs.w, h: lhs / rhs.h)
    }
    public static func /= (lhs: inout LiveSize, rhs: LiveSize) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w / rhs.w, h: _lhs.h / rhs.h)
    }
    public static func /= (lhs: inout LiveSize, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveSize(w: _lhs.w / rhs, h: _lhs.h / rhs)
    }
    
    
    public func flop() -> LiveSize {
        return LiveSize(w: h, h: w)
    }
    
}

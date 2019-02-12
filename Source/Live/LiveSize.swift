//
//  LiveSize.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-27.
//  Open Source - MIT License
//

import CoreGraphics

public class LiveSize: LiveValue, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var w: LiveFloat
    public var h: LiveFloat
    
    public var description: String {
        let _w: CGFloat = round(CGFloat(w) * 1_000) / 1_000
        let _h: CGFloat = round(CGFloat(h) * 1_000) / 1_000
        return "live(w:\("\(_w)".zfill(3)),h:\("\(_h)".zfill(3)))"
    }
    
    public var width: LiveFloat { return w }
    public var height: LiveFloat { return h }
    
    // MARK: Uniform
    
    var uniformIsNew: Bool {
        return w.uniformIsNew || h.uniformIsNew
    }
    
    var uniformList: [CGFloat] {
        return [w.uniform, h.uniform]
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

    // MARK: Life Cycle
    
    public init(_ futureValue: @escaping () -> (CGSize)) {
        w = LiveFloat({ return futureValue().width })
        h = LiveFloat({ return futureValue().height })
    }
    
    public init(w: LiveFloat, h: LiveFloat) {
        self.w = w
        self.h = h
    }
    
    public init(width: LiveFloat, height: LiveFloat) {
        w = width
        h = height
    }
    
    public init(frozen size: CGSize) {
        w = LiveFloat(frozen: size.width)
        h = LiveFloat(frozen: size.height)
    }
    
    required public init(floatLiteral value: FloatLiteralType) {
        w = LiveFloat(frozen: CGFloat(value))
        h = LiveFloat(frozen: CGFloat(value))
    }
    
    required public init(integerLiteral value: IntegerLiteralType) {
        w = LiveFloat(frozen: CGFloat(value))
        h = LiveFloat(frozen: CGFloat(value))
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
    
    /// filter over frames. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(frames: LiveInt, smooth: Bool = true) -> LiveSize {
        return LiveSize(w: w.filter(frames: frames, smooth: smooth), h: h.filter(frames: frames, smooth: smooth))
    }
    
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
        return LiveSize(w: LiveFloat.noise(range: wRange, for: seconds),
                        h: LiveFloat.noise(range: hRange, for: seconds))
    }
    
    // MARK: Helpers
    
    public static func fill(aspect: LiveFloat) -> LiveSize {
        return LiveSize(w: aspect, h: 1.0)
    }
    
//    public static func fill(res: PIX.Res) -> LiveSize {
//        return LiveSize.fill(aspect: LiveFloat(frozen: res.aspect))
//    }
    
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
    
}

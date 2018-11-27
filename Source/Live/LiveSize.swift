//
//  LiveSize.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-27.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class LiveSize: LiveValue, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var w: LiveFloat
    public var h: LiveFloat
    
    public var description: String {
        let _w: CGFloat = round(CGFloat(w) * 10_000) / 10_000
        let _h: CGFloat = round(CGFloat(h) * 10_000) / 10_000
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
    
    // MARK: Helpers
    
    public static func fill(aspect: LiveFloat) -> LiveSize {
        return LiveSize(w: aspect, h: 1.0)
    }
    
//    public static func fill(res: PIX.Res) -> LiveSize {
//        return LiveSize.fill(aspect: LiveFloat(frozen: res.aspect))
//    }
    
    // MARK: Equatable
    
//    public static func == (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveBool({ return CGFloat(lhs) == CGFloat(rhs) })
//    }
//    public static func != (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return !(lhs == rhs)
//    }
    
    // MARK: Comparable
    
//    public static func < (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveBool({ return CGFloat(lhs) < CGFloat(rhs) })
//    }
//    public static func <= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveBool({ return CGFloat(lhs) <= CGFloat(rhs) })
//    }
//    public static func > (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveBool({ return CGFloat(lhs) > CGFloat(rhs) })
//    }
//    public static func >= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveBool({ return CGFloat(lhs) >= CGFloat(rhs) })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w + rhs.w, h: lhs.h + rhs.h)
    }
    public static func + (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w + rhs, h: lhs.h + rhs)
    }
//    public static func += (lhs: inout LiveFloat, rhs: LiveFloat) {
//        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) + CGFloat(rhs) })
//    }
    
    public static func - (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w - rhs.w, h: lhs.h - rhs.h)
    }
    public static func - (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w - rhs, h: lhs.h - rhs)
    }
//    public static func -= (lhs: inout LiveFloat, rhs: LiveFloat) {
//        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) - CGFloat(rhs) })
//    }
    
    
    public static func * (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w * rhs.w, h: lhs.h * rhs.h)
    }
    public static func * (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w * rhs, h: lhs.h * rhs)
    }
//    public static func *= (lhs: inout LiveFloat, rhs: LiveFloat) {
//        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) * CGFloat(rhs) })
//    }
    
    public static func / (lhs: LiveSize, rhs: LiveSize) -> LiveSize {
        return LiveSize(w: lhs.w / rhs.w, h: lhs.h / rhs.h)
    }
    public static func / (lhs: LiveSize, rhs: LiveFloat) -> LiveSize {
        return LiveSize(w: lhs.w / rhs, h: lhs.h / rhs)
    }
//    public static func /= (lhs: inout LiveFloat, rhs: LiveFloat) {
//        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) / CGFloat(rhs) })
//    }
    
    
//    public static func ** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return pow(CGFloat(lhs), CGFloat(rhs)) })
//    }
//
//    public static func !** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return pow(CGFloat(lhs), 1.0 / CGFloat(rhs)) })
//    }
//
//    public static func % (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return CGFloat(lhs).truncatingRemainder(dividingBy: CGFloat(rhs)) })
//    }
    
    
//    public static func <> (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return min(CGFloat(lhs), CGFloat(rhs)) })
//    }
//
//    public static func >< (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return max(CGFloat(lhs), CGFloat(rhs)) })
//    }
    
    
//    public prefix static func - (operand: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return -CGFloat(operand) })
//    }
//
//    public prefix static func ! (operand: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return 1.0 - CGFloat(operand) })
//    }
    
    
//    public static func <=> (lhs: LiveFloat, rhs: LiveFloat) -> (LiveFloat, LiveFloat) {
//        return (lhs, rhs)
//    }
    
}

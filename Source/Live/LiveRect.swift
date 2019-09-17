//
//  LiveRect.swift
//  PixelKit
//
//  Created by Hexagons on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public class LiveRect: LiveValue, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var name: String?
    
    public var x: LiveFloat
    public var y: LiveFloat
    public var w: LiveFloat
    public var h: LiveFloat
    
    public var description: String {
        let _x: CGFloat = round(CGFloat(x) * 1_000) / 1_000
        let _y: CGFloat = round(CGFloat(y) * 1_000) / 1_000
        let _w: CGFloat = round(CGFloat(w) * 1_000) / 1_000
        let _h: CGFloat = round(CGFloat(h) * 1_000) / 1_000
        return "live\(name != nil ? "[\(name!)]" : "")(x:\("\(_x)".zfill(3)),y:\("\(_y)".zfill(3)),w:\("\(_w)".zfill(3)),h:\("\(_h)".zfill(3)))"
    }
    
    public var minX: LiveFloat { return x }
    public var minY: LiveFloat { return y }
    public var midX: LiveFloat { return x + w / 2 }
    public var midY: LiveFloat { return y + h / 2 }
    public var maxX: LiveFloat { return x + w }
    public var maxY: LiveFloat { return y + h }

    public var origin: LivePoint { return LivePoint(x: x, y: y) }
    public var center: LivePoint { return LivePoint(x: x + w / 2, y: y + h / 2) }
    
    public var width: LiveFloat { return w }
    public var height: LiveFloat { return h }
    public var size: LiveSize { return LiveSize(w: w, h: h) }
    
    public var centerTop: LivePoint { return LivePoint(x: x + w / 2, y: y + h) }
    public var centerBottom: LivePoint { return LivePoint(x: x + w / 2, y: y) }
    public var centerLeft: LivePoint { return LivePoint(x: x, y: y + h / 2) }
    public var centerRight: LivePoint { return LivePoint(x: x + w, y: y + h / 2) }
    public var topLeft: LivePoint { return LivePoint(x: x, y: y + h) }
    public var topRight: LivePoint { return LivePoint(x: x + w, y: y + h) }
    public var bottomLeft: LivePoint { return LivePoint(x: x, y: y) }
    public var bottomRight: LivePoint { return LivePoint(x: x + w, y: y) }
    
    // MARK: Uniform
    
    public var uniformIsNew: Bool {
        return x.uniformIsNew || y.uniformIsNew || w.uniformIsNew || h.uniformIsNew
    }
    
    public var uniformList: [CGFloat] {
        return [x.uniform, y.uniform, w.uniform, h.uniform]
    }
    
    public var cg: CGRect {
        return CGRect(x: x.cg, y: y.cg, width: w.cg, height: h.cg)
    }
    
    // MARK: - Life Cycle
    
    public init(_ liveValue: @escaping () -> (CGRect)) {
        x = LiveFloat({ return liveValue().minX })
        y = LiveFloat({ return liveValue().minY })
        w = LiveFloat({ return liveValue().width })
        h = LiveFloat({ return liveValue().height })
    }
    
    public init(x: LiveFloat, y: LiveFloat, w: LiveFloat, h: LiveFloat) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
    }
    
    public init(x: LiveFloat, y: LiveFloat, width: LiveFloat, height: LiveFloat) {
        self.x = x
        self.y = y
        w = width
        h = height
    }
    
    public init(origin: LivePoint, size: LiveSize) {
        x = origin.x
        y = origin.y
        w = size.w
        h = size.h
    }
    
    public init(center: LivePoint, size: LiveSize) {
        x = center.x - size.w / 2
        y = center.y - size.h / 2
        w = size.w
        h = size.h
    }
    
    public init(size: LiveSize, centered: LiveBool = false) {
        x = centered <?> -size.w / 2 <=> 0
        y = centered <?> -size.h / 2 <=> 0
        w = size.w
        h = size.h
    }
    
    public init(_ frame: CGRect) {
        x = LiveFloat(frame.minX)
        y = LiveFloat(frame.minY)
        w = LiveFloat(frame.width)
        h = LiveFloat(frame.height)
    }
    
    public init(name: String, frame: CGRect) {
        self.name = name
        x = LiveFloat(frame.minX)
        y = LiveFloat(frame.minY)
        w = LiveFloat(frame.width)
        h = LiveFloat(frame.height)
    }
    
    required public init(floatLiteral value: FloatLiteralType) {
        x = 0
        y = 0
        w = LiveFloat(CGFloat(value))
        h = LiveFloat(CGFloat(value))
    }
    
    required public init(integerLiteral value: IntegerLiteralType) {
        x = 0
        y = 0
        w = LiveFloat(CGFloat(value))
        h = LiveFloat(CGFloat(value))
    }
    
    // MARK: Flow Funcs
    
    public func delay(frames: LiveInt) -> LiveRect {
        return LiveRect(x: x.delay(frames: frames), y: y.delay(frames: frames), w: w.delay(frames: frames), h: h.delay(frames: frames))
    }
    
    public func delay(seconds: LiveFloat) -> LiveRect {
        return LiveRect(x: x.delay(seconds: seconds), y: y.delay(seconds: seconds), w: w.delay(seconds: seconds), h: h.delay(seconds: seconds))
    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true) -> LiveRect {
        return LiveRect(x: x.filter(seconds: seconds, smooth: smooth), y: y.filter(seconds: seconds, smooth: smooth),
                        w: w.filter(seconds: seconds, smooth: smooth), h: h.filter(seconds: seconds, smooth: smooth))
    }
    
    // MARK: Helpers
    
    public static func fill(aspect: LiveFloat) -> LiveRect {
        return LiveRect(x: 0, y: 0, w: aspect, h: 1.0)
    }
    
    public static func fill(res: PIX.Res) -> LiveRect {
        return LiveRect.fill(aspect: res.aspect)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveRect, rhs: LiveRect) -> LiveBool {
        return LiveBool({ return CGFloat(lhs.x) == CGFloat(rhs.x) && CGFloat(lhs.y) == CGFloat(rhs.y) &&
                                 CGFloat(lhs.w) == CGFloat(rhs.w) && CGFloat(lhs.h) == CGFloat(rhs.h) })
    }
    public static func != (lhs: LiveRect, rhs: LiveRect) -> LiveBool {
        return !(lhs == rhs)
    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveRect, rhs: LiveRect) -> LiveRect {
        let minPoint = LivePoint(x: min(lhs.x, rhs.x), y: min(lhs.y, rhs.y))
        let maxPoint = LivePoint(x: max(lhs.x, rhs.x), y: max(lhs.y, rhs.y))
        return LiveRect(origin: minPoint, size: (maxPoint - minPoint).size)
    }
    public static func + (lhs: LiveRect, rhs: LiveFloat) -> LiveRect {
        return LiveRect(x: lhs.x - rhs / 2, y: lhs.y - rhs / 2, w: lhs.w + rhs / 2, h: lhs.h + rhs / 2)
    }
    public static func + (lhs: LiveFloat, rhs: LiveRect) -> LiveRect {
        return rhs + lhs
    }
    public static func += (lhs: inout LiveRect, rhs: LiveRect) {
        lhs = lhs + rhs
    }
    public static func += (lhs: inout LiveRect, rhs: LiveFloat) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: LiveRect, rhs: LiveFloat) -> LiveRect {
        return LiveRect(x: lhs.x + rhs / 2, y: lhs.y + rhs / 2, w: lhs.w - rhs / 2, h: lhs.h - rhs / 2)
    }
    public static func - (lhs: LiveFloat, rhs: LiveRect) -> LiveRect {
        return rhs - lhs
    }
    public static func -= (lhs: inout LiveRect, rhs: LiveFloat) {
        lhs = lhs - rhs
    }
    
    public static func * (lhs: LiveRect, rhs: LiveFloat) -> LiveRect {
        return LiveRect(x: lhs.x - (lhs.size * rhs).w / 2, y: lhs.y - (lhs.size * rhs).h / 2,
                        w: lhs.w + (lhs.size * rhs).w / 2, h: lhs.h + (lhs.size * rhs).h / 2)
    }
    public static func * (lhs: LiveFloat, rhs: LiveRect) -> LiveRect {
        return rhs * lhs
    }
    public static func *= (lhs: inout LiveRect, rhs: LiveFloat) {
        lhs = lhs * rhs
    }
    
    public static func / (lhs: LiveRect, rhs: LiveFloat) -> LiveRect {
        return LiveRect(x: lhs.x - (lhs.size / rhs).w / 2, y: lhs.y - (lhs.size / rhs).h / 2,
                        w: lhs.w + (lhs.size / rhs).w / 2, h: lhs.h + (lhs.size / rhs).h / 2)
    }
    public static func /= (lhs: inout LiveRect, rhs: LiveFloat) {
        lhs = lhs / rhs
    }
    
}

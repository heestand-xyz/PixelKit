//
//  LiveInt.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics

extension Int {
    init(_ liveInt: LiveInt) {
        self = liveInt.value
    }
}

public class LiveInt: LiveValue, /*Equatable, Comparable,*/ ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var name: String?
    
    public var description: String {
        return "live\(name != nil ? "[\(name!)]" : "")(\(value))"
    }
    
    var liveValue: () -> (Int)
    var value: Int {
        return liveValue()
//        guard limit else { return liveValue() }
//        return Swift.max(Swift.min(liveValue(), max), min)
    }
    
    var uniform: Int {
        uniformCache = value
        return value
    }
    var uniformIsNew: Bool {
        return uniformCache != value
    }
    var uniformCache: Int? = nil
    
    public var val: Int {
        return value
    }
    
    public static var touch: LiveInt {
        return LiveInt({ () -> (Int) in
            return Bool(LiveBool.touch) ? 1 : 0
        })
    }
    
//    var limit: Bool = false
//    var min: CGFloat = 0.0
//    var max: CGFloat = 1.0
    
    
//    public var year: LiveInt!
//    public var month: LiveInt!
//    public var day: LiveInt!
//    public var hour: LiveInt!
//    public var minute: LiveInt!
//    public var second: LiveInt!
    public static var seconds: LiveInt {
        return LiveInt({ () -> (Int) in
            return Int(Pixels.main.seconds)
        })
    }
    public static var secondsSince1970: LiveInt {
        return LiveInt({ () -> (Int) in
            return Int(Date().timeIntervalSince1970)
        })
    }
    
    
    public init(_ liveValue: @escaping () -> (Int)) {
        self.liveValue = liveValue
    }
    
    public init(_ liveFloat: LiveFloat) {
        liveValue = { return Int(liveFloat.value) }
    }
    
    public init(_ value: CGFloat) {
        liveValue = { return Int(value) }
    }
    
    public init(_ value: Int) {
        liveValue = { return value }
    }
    required public init(integerLiteral value: IntegerLiteralType) {
        liveValue = { return Int(value) }
    }
    
//    public init(name: String, value: Int, min: CGFloat, max: CGFloat) {
//        self.name = name
//        self.min = min
//        self.max = max
//        self.name = name
//        liveValue = { return value }
//    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveInt, rhs: LiveInt) -> LiveBool {
        return LiveBool({ return lhs.value == rhs.value })
    }
    
//    public static func == (lhs: LiveInt, rhs: Int) -> LiveBool {
//        return lhs.value == rhs
//    }
//    public static func == (lhs: Int, rhs: LiveInt) -> LiveBool {
//        return lhs == rhs.value
//    }
    
    // MARK: Comparable
    
    public static func < (lhs: LiveInt, rhs: LiveInt) -> LiveBool {
        return LiveBool({ return lhs.value < rhs.value })
    }
//    public static func < (lhs: LiveInt, rhs: Int) -> LiveBool {
//        return LiveInt({ return lhs.value < rhs })
//    }
//    public static func < (lhs: Int, rhs: LiveInt) -> LiveBool {
//        return LiveInt({ return lhs < rhs.value })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value + rhs.value })
    }
    
    public static func - (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value - rhs.value })
    }
    
    public static func * (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value * rhs.value })
    }
//    public static func *= (lhs: inout LiveInt, rhs: LiveInt) {
//        lhs.liveValue = { return lhs.value * rhs.value }
//    }
    
    public static func / (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value / rhs.value })
    }
//    public static func / (lhs: LiveInt, rhs: Int) -> LiveInt {
//        return LiveInt({ return lhs.value / rhs })
//    }
//    public static func / (lhs: Int, rhs: LiveInt) -> LiveInt {
//        return LiveInt({ return lhs / rhs.value })
//    }
    
    public static func <> (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return min(lhs.value, rhs.value) })
    }
    
    public static func >< (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return max(lhs.value, rhs.value) })
    }
    
    
    public prefix static func - (operand: LiveInt) -> LiveInt {
        return LiveInt({ return -operand.value })
    }
    
    
    public static func <=> (lhs: LiveInt, rhs: LiveInt) -> (LiveInt, LiveInt) {
        return (lhs, rhs)
    }
    
    // MARK: Local Funcs
    
    public static func random(in range: Range<Int>) -> LiveInt {
        return LiveInt(Int.random(in: range))
    }
    public static func random(in range: ClosedRange<Int>) -> LiveInt {
        return LiveInt(Int.random(in: range))
    }
    
    public static func liveRandom(in range: Range<Int>) -> LiveInt {
        return LiveInt({ return Int.random(in: range) })
    }
    public static func liveRandom(in range: ClosedRange<Int>) -> LiveInt {
        return LiveInt({ return Int.random(in: range) })
    }
    
}

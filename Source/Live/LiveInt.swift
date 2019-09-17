//
//  LiveInt.swift
//  PixelKit
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
        guard limit else { return liveValue() }
        return Swift.max(Swift.min(liveValue(), max), min)
    }
    
    public var limit: Bool = false
    public var min: Int = 0
    public var max: Int = 1
    public var range: Range<Int> {
        min..<max
    }
    
    public var uniform: Int {
        uniformCache = value
        return value
    }
    public var uniformIsNew: Bool {
        return uniformCache != value
    }
    var uniformCache: Int? = nil
    
    public var val: Int {
        return value
    }
    
    #if os(iOS)
    public static var touch: LiveInt {
        return LiveInt({ () -> (Int) in
            return Bool(LiveBool.touch) ? 1 : 0
        })
    }
    #endif
    
    #if os(macOS)
    
    public static var midiAny: LiveInt {
        return LiveInt({ () -> (Int) in
            return MIDI.main.firstAnyRaw ?? 0
        })
    }
    
    #endif
    
//    public var year: LiveInt!
//    public var month: LiveInt!
//    public var day: LiveInt!
//    public var hour: LiveInt!
//    public var minute: LiveInt!
//    public var second: LiveInt!
    public static var seconds: LiveInt {
        return LiveInt({ () -> (Int) in
            return Int(PixelKit.main.seconds)
        })
    }
    public static var secondsSince1970: LiveInt {
        return LiveInt({ () -> (Int) in
            return Int(Date().timeIntervalSince1970)
        })
    }
    
    public static var frameIndex: LiveInt {
        var index: Int = 0
        return LiveInt({ () -> (Int) in
            index += 1
            return index
        })
    }
    
    // MARK: - Life Cycle
    
    public init(_ liveValue: @escaping () -> (Int)) {
        self.liveValue = liveValue
    }
    
    public init(_ liveFloat: LiveFloat) {
        liveValue = { return Int(liveFloat.value) }
    }
    
    public init(_ value: CGFloat) {
        liveValue = { return Int(value) }
    }
    
    public init(_ value: Int, min: Int? = nil, max: Int? = nil, limit: Bool = false) {
        liveValue = { return value }
        self.min = min ?? 0
        self.max = max ?? 1
        self.limit = limit
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
        return LiveInt({ return Swift.min(lhs.value, rhs.value) })
    }
    
    public static func >< (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return Swift.max(lhs.value, rhs.value) })
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
    
    #if os(macOS)
    public static func midi(_ address: String) -> LiveInt {
        return LiveInt({ return (MIDI.main.listRaw[address] ?? 0) ?? 0 })
    }
    #endif
    
}

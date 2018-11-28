//
//  LiveInt.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics

extension Int {
    init(_ liveInt: LiveInt) {
        self = liveInt.value
    }
}

public class LiveInt: LiveValue, /*Equatable, Comparable,*/ ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var description: String {
        return "live(\(value))"
    }
    
    var futureValue: () -> (Int)
    var value: Int {
        return futureValue()
    }
    
    var uniform: Int {
        uniformCache = value
        return value
    }
    var uniformIsNew: Bool {
        return uniformCache != value
    }
    var uniformCache: Int? = nil
    
    
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
    
    
    public init(_ futureValue: @escaping () -> (Int)) {
        self.futureValue = futureValue
    }
    
    public init(_ liveFloat: LiveFloat) {
        futureValue = { return Int(liveFloat.value) }
    }
    
    // Figure out Frozen
    public init(frozen value: Int) {
        futureValue = { return value }
    }
    
    public init(_ value: CGFloat) {
        futureValue = { return Int(value) }
    }
    
    public init(_ value: Int) {
        futureValue = { return value }
    }
    required public init(integerLiteral value: IntegerLiteralType) {
        futureValue = { return Int(value) }
    }
    
//    enum CodingKeys: String, CodingKey {
//        case rawValue; case liveKey
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
//        lhs.futureValue = { return lhs.value * rhs.value }
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
    
}

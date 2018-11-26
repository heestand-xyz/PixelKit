//
//  LiveFloat.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics

public struct LiveFloat: LiveValue, /*Equatable, Comparable,*/ ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible/*, BinaryFloatingPoint */ {
    
    public var description: String {
        return "live(\(value))"
    }
    
    var futureValue: () -> (CGFloat)
    public var value: CGFloat {
        return futureValue()
    }
    
    var pxv: CGFloat {
        mutating get {
            pxvCache = value
            return value
        }
    }
    var pxvIsNew: Bool {
        return pxvCache != value
    }
    var pxvCache: CGFloat? = nil
    
    
    //    public var year: LiveFloat!
    //    public var month: LiveFloat!
    //    public var day: LiveFloat!
    //    public var hour: LiveFloat!
    //    public var minute: LiveFloat!
    //    public var second: LiveFloat!
    public static var seconds: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return Pixels.main.seconds
        })
    }
    public static var secondsSince1970: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return CGFloat(Date().timeIntervalSince1970)
        })
    }
    
    
    public init(_ futureValue: @escaping () -> (CGFloat)) {
        self.futureValue = futureValue
    }
    
    public init(_ liveInt: LiveInt) {
        futureValue = { return CGFloat(liveInt.value) }
    }
    
    public init(static value: CGFloat) {
        futureValue = { return CGFloat(value) }
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
//    enum CodingKeys: String, CodingKey {
//        case rawValue; case liveKey
//    }
    
//    func filter(for seconds: LiveFloat) -> LiveFloat {
//        // ...
//    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return lhs.value == rhs.value })
    }
    public static func != (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return !(lhs == rhs)
    }
//    public static func == (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return lhs.value == rhs
//    }
//    public static func == (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return lhs == rhs.value
//    }
    
    // MARK: Comparable
    
    public static func < (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return lhs.value < rhs.value })
    }
    public static func <= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return lhs.value <= rhs.value })
    }
    public static func > (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return lhs.value > rhs.value })
    }
    public static func >= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return lhs.value >= rhs.value })
    }
//    public static func < (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return LiveFloat({ return lhs.value < rhs })
//    }
//    public static func < (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveFloat({ return lhs < rhs.value })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value + rhs.value })
    }
    
    public static func - (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value - rhs.value })
    }
    
    
    public static func * (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value * rhs.value })
    }
//    public static func *= (lhs: inout LiveFloat, rhs: LiveFloat) {
//        lhs.futureValue = { return lhs.value * rhs.value }
//    }
    
    public static func / (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value / rhs.value })
    }
//    public static func / (lhs: LiveFloat, rhs: CGFloat) -> LiveFloat {
//        return LiveFloat({ return lhs.value / rhs })
//    }
//    public static func / (lhs: CGFloat, rhs: LiveFloat) -> LiveFloat {
//        return LiveFloat({ return lhs / rhs.value })
//    }
    
    
    public static func ** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(lhs.value, rhs.value) })
    }
    
    public static func !** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(lhs.value, 1.0 / rhs.value) })
    }
    
    public static func % (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value.truncatingRemainder(dividingBy: rhs.value) })
    }
    
    
    public static func <> (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return min(lhs.value, rhs.value) })
    }
    
    public static func >< (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return max(lhs.value, rhs.value) })
    }
    
    
    public prefix static func - (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return -operand.value })
    }
    
    public prefix static func ! (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return 1.0 - operand.value })
    }
    
    
    public static func <=> (lhs: LiveFloat, rhs: LiveFloat) -> (LiveFloat, LiveFloat) {
        return (lhs, rhs)
    }
    
    // MARK: Local Funcs
    
    public func truncatingRemainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return self.value.truncatingRemainder(dividingBy: other.value) })
    }

    public func remainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return self.value.remainder(dividingBy: other.value) })
    }
    
}


// MARK: Global Funcs

func round(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return round(live.value) })
}
func floor(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return floor(live.value) })
}
func ceil(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return ceil(live.value) })
}

func sqrt(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return sqrt(live.value) })
}
func pow(_ live: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return pow(live.value, live2.value) })
}

func atan(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan(live.value) })
}
func atan2(_ live: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan2(live.value, live2.value) })
}

// MARK: New Global Funcs

func deg(rad live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (live.value / .pi / 2.0) * 360.0 })
}
func rad(deg live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (live.value / 360.0) * .pi * 2.0 })
}

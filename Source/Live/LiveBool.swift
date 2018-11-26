//
//  LiveBool.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

//infix operator *%* { precedence 50 }
//infix operator %*% { precedence 60 }
//{ associativity left }

precedencegroup TernaryIf {
    associativity: right
    lowerThan: ComparisonPrecedence
    higherThan: AssignmentPrecedence
}
precedencegroup TernaryElse {
    associativity: left
    higherThan: ComparisonPrecedence
}

infix operator <?: TernaryIf
infix operator <=>: TernaryElse

public struct LiveBool: LiveValue, ExpressibleByBooleanLiteral, CustomStringConvertible {
    
    public var description: String {
        return "live(\(value))"
    }
    
    var futureValue: () -> (Bool)
    public var value: Bool {
        return futureValue()
    }
    
    var pxv: Bool {
        mutating get {
            pxvCache = value
            return value
        }
    }
    var pxvIsNew: Bool {
        return pxvCache != value
    }
    var pxvCache: Bool? = nil
    
    
    
    public init(_ futureValue: @escaping () -> (Bool)) {
        self.futureValue = futureValue
    }
    
    public init(static value: Bool) {
        futureValue = { return value }
    }
    
    public init(booleanLiteral value: BooleanLiteralType) {
        futureValue = { return value }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return lhs.value == rhs.value })
    }
    
    public static func && (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return lhs.value && rhs.value })
    }
    
    public static func || (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return lhs.value || rhs.value })
    }
    
    
    public prefix static func ! (operand: LiveBool) -> LiveBool {
        return LiveBool({ return !operand.value })
    }
    
//    public static func .? (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
//        return lhs //...
//    }
    
    public static func <? (lhs: LiveBool, rhs: (LiveFloat, LiveFloat)) -> LiveFloat {
        return LiveFloat({ return lhs.value ? rhs.0.value : rhs.1.value })
    }
    public static func <? (lhs: LiveBool, rhs: (LiveInt, LiveInt)) -> LiveInt {
        return LiveInt({ return lhs.value ? rhs.0.value : rhs.1.value })
    }
    
    public static func ? : (lhs: LiveBool, rhs: (LiveInt, LiveInt)) -> LiveInt {
        return LiveInt({ return lhs.value ? rhs.0.value : rhs.1.value })
    }
    
}

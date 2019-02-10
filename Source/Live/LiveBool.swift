//
//  LiveBool.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics

//infix operator *%* { precedence 50 }
//infix operator %*% { precedence 60 }
//{ associativity left }

precedencegroup TernaryIf {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: ComparisonPrecedence
}
precedencegroup TernaryElse {
    associativity: left
    higherThan: ComparisonPrecedence
    lowerThan: MultiplicationPrecedence
}

infix operator <?>: TernaryIf
infix operator <=>: TernaryElse

extension Bool {
    init(_ liveBool: LiveBool) {
        self = liveBool.value
    }
}

public class LiveBool: LiveValue, ExpressibleByBooleanLiteral, CustomStringConvertible {
    
    var name: String?
    
    public var description: String {
        return "live(\(Bool(self)))"
    }
    
    var futureValue: () -> (Bool)
    var value: Bool {
        return futureValue()
    }
    
    var uniform: Bool {
        uniformCache = Bool(self)
        return Bool(self)
    }
    var uniformIsNew: Bool {
        return uniformCache != Bool(self)
    }
    var uniformCache: Bool? = nil
    
    
    
    public init(_ futureValue: @escaping () -> (Bool)) {
        self.futureValue = futureValue
    }
    
    required public init(booleanLiteral value: BooleanLiteralType) {
        futureValue = { return value }
    }
    
    public init(name: String, value: Bool) {
        self.name = name
        futureValue = { return value }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) == Bool(rhs) })
    }
    
    public static func && (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) && Bool(rhs) })
    }
    
    public static func || (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) || Bool(rhs) })
    }
    
    
    public prefix static func ! (operand: LiveBool) -> LiveBool {
        return LiveBool({ return !Bool(operand) })
    }
    
//    public static func .? (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
//        return lhs //...
//    }
    
    public static func <?> (lhs: LiveBool, rhs: (LiveFloat, LiveFloat)) -> LiveFloat {
        return LiveFloat({ return Bool(lhs) ? CGFloat(rhs.0) : CGFloat(rhs.1) })
    }
    public static func <?> (lhs: LiveBool, rhs: (LiveInt, LiveInt)) -> LiveInt {
        return LiveInt({ return Bool(lhs) ? Int(rhs.0) : Int(rhs.1) })
    }
    
}

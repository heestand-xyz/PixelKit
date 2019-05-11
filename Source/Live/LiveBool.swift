//
//  LiveBool.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

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
    
    public var name: String?
    
    public var description: String {
        return "live\(name != nil ? "[\(name!)]" : "")(\(Bool(self)))"
    }
    
    var liveValue: () -> (Bool)
    var value: Bool {
        return liveValue()
    }
    
    public var uniform: Bool {
        uniformCache = Bool(self)
        return Bool(self)
    }
    public var uniformIsNew: Bool {
        return uniformCache != Bool(self)
    }
    var uniformCache: Bool? = nil
    
    public var val: Bool {
        return value
    }
    
    #if os(iOS)
    public static var touch: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveTouchView.touch {
                    return true
                }
            }
            return false
        })
    }
    #elseif os(macOS)
    public static var mouseLeft: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseLeft {
                    return true
                }
            }
            return false
        })
    }
    public static var mouseRight: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseRight {
                    return true
                }
            }
            return false
        })
    }
    public static var mouseInView: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseInView {
                    return true
                }
            }
            return false
        })
    }
    #endif
    
    #if os(macOS)
    
    public static var midiAny: LiveBool {
        return LiveBool({ return LiveInt.midiAny.val > 0 })
    }
    
    #endif
    
    public init(_ liveValue: @escaping () -> (Bool)) {
        self.liveValue = liveValue
    }
    
    public init(_ value: Bool) {
        liveValue = { return value }
    }
    
    required public init(booleanLiteral value: BooleanLiteralType) {
        liveValue = { return value }
    }
    
    public init(name: String, value: Bool) {
        self.name = name
        self.name = name
        liveValue = { return value }
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
    public static func <?> (lhs: LiveBool, rhs: (LiveColor, LiveColor)) -> LiveColor {
        return LiveColor({ return Bool(lhs) ? rhs.0._color : rhs.1._color })
    }
    
    #if os(macOS)
    /// find addresses with `MIDI.main.log = true`
    public static func midi(_ address: String) -> LiveBool {
        return LiveBool({ return LiveInt.midi(address).val > 0 })
    }
    #endif
    
}

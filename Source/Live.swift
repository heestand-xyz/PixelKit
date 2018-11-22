//
//  Live.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics

public /*private*/ class Live {
    
    public static let now = Live()
    
    let start = Date()
    
//    public var touch: LivePoint?
//    public var touchDown: LiveBool
//    public var multiTouch: LivePointArray
//    public var mouse: LivePoint
//    public var mouseLeft: LiveBool
//    public var mouseRight: LiveBool
//
//    public var darkMode: LiveBool
//
//    public var year: LiveInt!
//    public var month: LiveInt!
//    public var day: LiveInt!
//    public var hour: LiveInt!
//    public var minute: LiveInt!
//    public var second: LiveInt!
    
    let lf: LiveFloat
    
    init() {
        lf = .secondsSinceLaunch
    }
    
    public func test() {
        print(lf)
    }
    
}




protocol LiveValue: Codable {
    
    var futureValue: () -> (CGFloat) { get set }
    var value: CGFloat { get }
    
    var pxv: CGFloat { mutating get }
    var pxvIsNew: Bool { get }
    var pxvCache: CGFloat? { get set }
    
}

//protocol LiveValueConvertable {
////    func *(lhs: Self, rhs: Self) -> Self
//    init(_: FloatLiteralType)
//}
//
//extension Double : LiveValueConvertable {}
//extension Float : LiveValueConvertable {}
//extension CGFloat : LiveValueConvertable {}

public struct LiveFloat: LiveValue, Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
//    public typealias FloatLiteralType = Double
//    public typealias IntegerLiteralType = Int
    
    public var description: String {
        return "live(\(value))"
    }
    
//    public typealias NativeType = CGFloat
//    public var native: LiveFloat.NativeType
    
    
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
    
    
    //    public var years: LiveFloat!
    //    public var months: LiveFloat!
    //    public var days: LiveFloat!
    //    public var hours: LiveFloat!
    //    public var minutes: LiveFloat!
    //    public var seconds: LiveFloat!
    public static var secondsSinceLaunch: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return Pixels.main.seconds
        })
    }
    public static var secondsSince1970: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return CGFloat(-Date().timeIntervalSince1970)
        })
    }

    
    public init(_ futureValue: @escaping () -> (CGFloat)) {
        self.futureValue = futureValue
        
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
//    public init(_ value: Double) {
//        futureValue = { return CGFloat(value) }
//    }
    
    enum CodingKeys: String, CodingKey {
        case rawValue; case liveKey
    }
    
    required convenience init(from decoder: Decoder) throws {
//        self.init(
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        //        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
        color = try container.decode(Color.self, forKey: .color)
        edgeColor = try container.decode(Color.self, forKey: .edgeColor)
        bgColor = try container.decode(Color.self, forKey: .bgColor)
        setNeedsRender()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if value..
        try container.encode(position, forKey: .rawValue)
        try container.encode(color, forKey: .liveKey)
        try container.encode(edgeColor, forKey: .edgeColor)
        try container.encode(bgColor, forKey: .bgColor)
    }
    
//    func filter(for seconds: LiveFloat) -> LiveFloat {
//        // ...
//    }
    
    public static func == (lhs: LiveFloat, rhs: LiveFloat) -> Bool {
        return lhs.value == rhs.value
    }
    public static func == (lhs: LiveFloat, rhs: CGFloat) -> Bool {
        return lhs.value == rhs
    }
    public static func == (lhs: CGFloat, rhs: LiveFloat) -> Bool {
        return lhs == rhs.value
    }
    
    
    public static func + (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value + rhs.value })
    }
    
    public static func - (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value - rhs.value })
    }
    
    
    public static func * (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value * rhs.value })
    }
    
    public static func / (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value / rhs.value })
    }
    public static func / (lhs: LiveFloat, rhs: CGFloat) -> LiveFloat {
        return LiveFloat({ return lhs.value / rhs })
    }
    public static func / (lhs: CGFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return lhs / rhs.value })
    }
    
    
    public static func ** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(lhs.value, rhs.value) })
    }
    
    public static func !** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(lhs.value, 1.0 / rhs.value) })
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
    
    
    static func sqrt(_ live: LiveFloat) -> LiveFloat {
        return LiveFloat({ return Darwin.sqrt(live.value) })
    }
    
}

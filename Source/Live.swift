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

extension CGFloat {
    
}

public struct LiveFloat: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public var description: String {
        return "\(value)"
    }
    
//    public typealias NativeType = CGFloat
//    public var native: LiveFloat.NativeType
    
    
    var futureValue: () -> (CGFloat)
    public var value: CGFloat {
        return futureValue()
    }
    
    var liveValue: CGFloat {
        mutating get {
            liveLast = value
            return value
        }
    }
    var newLive: Bool {
        return liveLast != value
    }
    var liveLast: CGFloat? = nil
    
    
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
    
}

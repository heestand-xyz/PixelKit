//
//  Live.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics

public /*private*/ class Live: Codable {
    
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
    
    func debug() {
        let live: LiveFloat = floor(.secondsSinceLaunch)
    }
    
}


//protocol LiveValueConvertable {
////    func *(lhs: Self, rhs: Self) -> Self
//    init(_: FloatLiteralType)
//}
//
//extension Double : LiveValueConvertable {}
//extension Float : LiveValueConvertable {}
//extension CGFloat : LiveValueConvertable {}

//extension CGFloat {
//    init(_ live: LiveFloat) {
//        self.init(live.value)
//    }
//}

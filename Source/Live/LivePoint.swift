//
//  LivePoint.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-27.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public struct LivePoint: LiveValue, CustomStringConvertible {
    
    public var x: LiveFloat
    public var y: LiveFloat
    
    public var description: String {
        let _x: CGFloat = round(CGFloat(x) * 10_000) / 10_000
        let _y: CGFloat = round(CGFloat(y) * 10_000) / 10_000
        return "live(x:\("\(_x)".zfill(3)),y:\("\(_y)".zfill(3)))"
    }
    
    // MARK: PXV
    
    var pxvIsNew: Bool {
        return x.pxvIsNew || y.pxvIsNew
    }
    
    var pxvList: [CGFloat] {
        mutating get {
            return [x.pxv, y.pxv]
        }
    }
    
    // MARK: Points
    
//    public static var circle: LiveColor {
//    }
    
    public static var zero: LivePoint { return LivePoint(x: 0.0, y: 0.0) }
    
    // MARK: Life Cycle
    
    public init(x: LiveFloat, y: LiveFloat) {
        self.x = x
        self.y = y
    }
    
    public init(point: CGPoint) {
        x = LiveFloat(static: point.x)
        y = LiveFloat(static: point.y)
    }
    
    public init(vector: CGVector) {
        x = LiveFloat(static: vector.dx)
        y = LiveFloat(static: vector.dy)
    }
    
    // MARK: Helpers
    
    public static func topLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(static: -res.aspect / 2.0), y: 0.5)
    }
    public static func topRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(static: res.aspect / 2.0), y: 0.5)
    }
    public static func bottomLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(static: -res.aspect / 2.0), y: -0.5)
    }
    public static func bottomRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: LiveFloat(static: res.aspect / 2.0), y: -0.5)
    }
    
}

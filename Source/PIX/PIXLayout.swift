//
//  PIXLayout.swift
//  Pixels
//
//  Created by Hexagons on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics
#if os(iOS)
import UIKit
#endif

public enum LayoutXAnchor {
    case left
    case center
    case right
}

public enum LayoutYAnchor {
    case bottom
    case center
    case top
}

public protocol Layoutable {
    
    var frame: LiveRect { get set }
    var frameRotation: LiveFloat { get set }

    func reFrame(to frame: LiveRect)

    func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat)
    
    func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: LiveFloat)

}

public extension PIX {
    
    func point(of point: CGPoint) -> CGPoint {
        let uv = CGPoint(x: point.x / view.metalView.bounds.width, y: point.y / view.metalView.bounds.height)
        let aspect = view.metalView.bounds.width / view.metalView.bounds.height
        let point = CGPoint(x: (uv.x - 0.5) * aspect, y: (uv.y - 0.5) * -1)
        return point
    }
    
    func point(of livePoint: LivePoint) -> LivePoint {
        return LivePoint(point(of: livePoint.cg))
    }
    
    #if os(iOS)
    func point(of touch: UITouch) -> LivePoint {
        let location = touch.location(in: view.metalView)
        return LivePoint(point(of: location))
    }
    #endif
    
}

class Layout {
    
    // MARK: X
    
    static func anchorX(target layoutable: Layoutable, _ targetAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceAnchor: LayoutXAnchor, constant: LiveFloat) {
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .left:
            sourceValue = sourceFrame.x + constant
        case .center:
            sourceValue = sourceFrame.center.x + constant
        case .right:
            sourceValue = sourceFrame.centerRight.x + constant
        }
        Layout.anchorX(target: layoutable, targetAnchor, to: sourceValue)
    }
    
    static func anchorX(target layoutablePix: PIX & Layoutable, _ targetAnchor: LayoutXAnchor, toBoundAnchor sourceAnchor: LayoutXAnchor, constant: LiveFloat) {
        let aspect = LiveFloat({ return layoutablePix.resolution?.aspect.cg ?? 1.0 })
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .left:
            sourceValue = -aspect / 2 + constant
        case .center:
            sourceValue = constant
        case .right:
            sourceValue = aspect / 2 + constant
        }
        Layout.anchorX(target: layoutablePix, targetAnchor, to: sourceValue)
    }
    
    static func anchorX(target layoutable: Layoutable, _ targetAnchor: LayoutXAnchor, to sourceValue: LiveFloat) {
        var layoutable = layoutable
        switch targetAnchor {
        case .left:
            layoutable.frame = LiveRect(x: sourceValue,
                                        y: layoutable.frame.y,
                                        w: layoutable.frame.maxX - sourceValue,
                                        h: layoutable.frame.h)
        case .center:
            layoutable.frame = LiveRect(x: sourceValue - layoutable.frame.w / 2,
                                        y: layoutable.frame.y,
                                        w: layoutable.frame.w,
                                        h: layoutable.frame.h)
        case .right:
            layoutable.frame = LiveRect(x: layoutable.frame.x,
                                        y: layoutable.frame.y,
                                        w: sourceValue - layoutable.frame.minX,
                                        h: layoutable.frame.h)
        }
    }
    
    // MARK: Y
    
    static func anchorY(target layoutable: Layoutable, _ targetAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceAnchor:
        LayoutYAnchor, constant: LiveFloat) {
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .bottom:
            sourceValue = sourceFrame.y + constant
        case .center:
            sourceValue = sourceFrame.center.y + constant
        case .top:
            sourceValue = sourceFrame.centerTop.y + constant
        }
        Layout.anchorY(target: layoutable, targetAnchor, to: sourceValue)
    }
    
    static func anchorY(target layoutablePix: Layoutable, _ targetAnchor: LayoutYAnchor, toBoundAnchor sourceAnchor: LayoutYAnchor, constant: LiveFloat) {
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .bottom:
            sourceValue = -0.5 + constant
        case .center:
            sourceValue = constant
        case .top:
            sourceValue = 0.5 + constant
        }
        Layout.anchorY(target: layoutablePix, targetAnchor, to: sourceValue)
    }
    
    static func anchorY(target layoutable: Layoutable, _ targetAnchor: LayoutYAnchor, to sourceValue: LiveFloat) {
        var layoutable = layoutable
        switch targetAnchor {
        case .bottom:
            layoutable.frame = LiveRect(x: layoutable.frame.x,
                                        y: sourceValue,
                                        w: layoutable.frame.w,
                                        h: layoutable.frame.maxY - sourceValue)
        case .center:
            layoutable.frame = LiveRect(x: layoutable.frame.x,
                                        y: sourceValue - layoutable.frame.h / 2,
                                        w: layoutable.frame.w,
                                        h: layoutable.frame.h)
        case .top:
            layoutable.frame = LiveRect(x: layoutable.frame.x,
                                        y: layoutable.frame.y,
                                        w: layoutable.frame.w,
                                        h: sourceValue - layoutable.frame.minY)
        }
    }
    
}

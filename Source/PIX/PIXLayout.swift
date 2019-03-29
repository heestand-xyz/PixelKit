//
//  PIXLayout.swift
//  Pixels
//
//  Created by Hexagons on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

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
    
    func reFrame(to frame: LiveRect, update: Bool)
    func reFrame(to layoutable: Layoutable)
//    func reCenter(to layoutable: Layoutable)
//    func reSize(to layoutable: Layoutable)

    func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat)
    
    func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: LiveFloat)
    func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: LiveFloat)

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
        let aspect = LiveFloat({ return layoutablePix.resolution?.aspect ?? 1.0 })
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
        switch targetAnchor {
        case .left:
            layoutable.reFrame(to: LiveRect(x: sourceValue,
                                            y: layoutable.frame.y,
                                            w: layoutable.frame.maxX - sourceValue,
                                            h: layoutable.frame.h), update: true)
        case .center:
            layoutable.reFrame(to: LiveRect(x: sourceValue - layoutable.frame.w / 2,
                                            y: layoutable.frame.y,
                                            w: layoutable.frame.w,
                                            h: layoutable.frame.h), update: true)
        case .right:
            layoutable.reFrame(to: LiveRect(x: layoutable.frame.x,
                                            y: layoutable.frame.y,
                                            w: sourceValue - layoutable.frame.minX,
                                            h: layoutable.frame.h), update: true)
        }
    }
    
    // MARK: Y
    
    static func anchorY(target layoutable: Layoutable, _ targetAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceAnchor: LayoutYAnchor, constant: LiveFloat) {
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
        switch targetAnchor {
        case .bottom:
            layoutable.reFrame(to: LiveRect(x: layoutable.frame.x,
                                            y: sourceValue,
                                            w: layoutable.frame.w,
                                            h: layoutable.frame.maxY - sourceValue), update: true)
        case .center:
            layoutable.reFrame(to: LiveRect(x: layoutable.frame.x,
                                            y: sourceValue - layoutable.frame.h / 2,
                                            w: layoutable.frame.w,
                                            h: layoutable.frame.h), update: true)
        case .top:
            layoutable.reFrame(to: LiveRect(x: layoutable.frame.x,
                                            y: layoutable.frame.y,
                                            w: layoutable.frame.w,
                                            h: sourceValue - layoutable.frame.minY), update: true)
        }
    }
    
}

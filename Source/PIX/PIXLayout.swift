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
    
    func reFrame(to frame: LiveRect)
    func reFrame(to layoutable: Layoutable)
//    func reCenter(to layoutable: Layoutable)
//    func reSize(to layoutable: Layoutable)

    func anchor(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor)
    func anchor(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor)
    func anchor(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor)
    func anchor(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor)

}

class Layout {
    
    static func anchor(target layoutable: Layoutable, _ targetAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceAnchor: LayoutXAnchor) {
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .left:
            sourceValue = sourceFrame.x
        case .center:
            sourceValue = sourceFrame.center.x
        case .right:
            sourceValue = sourceFrame.centerRight.x
        }
//        let targetValue: LiveFloat
        switch targetAnchor {
        case .left:
            layoutable.reFrame(to: LiveRect(x: sourceValue, y: layoutable.frame.y,
                                            w: layoutable.frame.maxX - sourceValue, h: layoutable.frame.h))
        case .center:
//            targetValue = sourceValue - layoutable.frame.w / 2
            break
        case .right:
            break
//            layoutable.reFrame(to: LiveRect(x: sourceValue - layoutable.frame.w, y: layoutable.frame.y,
//                                            w: sourceValue - layoutable.frame.minX, h: layoutable.frame.h))
        }
    }
    
    static func anchor(target layoutable: Layoutable, _ targetAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceAnchor: LayoutYAnchor) {
        let sourceValue: LiveFloat
        switch sourceAnchor {
        case .bottom:
            sourceValue = sourceFrame.y
        case .center:
            sourceValue = sourceFrame.center.y
        case .top:
            sourceValue = sourceFrame.centerTop.y
        }
        let targetValue: LiveFloat
        switch targetAnchor {
        case .bottom:
            targetValue = sourceValue
        case .center:
            targetValue = sourceValue - layoutable.frame.h / 2
        case .top:
            targetValue = sourceValue - layoutable.frame.h
        }
        layoutable.reFrame(to: LiveRect(x: layoutable.frame.x, y: targetValue, w: layoutable.frame.w, h: layoutable.frame.maxY - targetValue))
    }
    
}

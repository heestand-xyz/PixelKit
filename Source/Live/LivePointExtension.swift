//
//  CGPointExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics
import LiveValues
import RenderKit
#if os(macOS)
import AppKit
#endif

extension CGPoint {
    
    // MARK: - Touch / Mouse
    
    #if os(iOS)
    public static var touchXY: CGPoint {
        return CGPoint({ () -> (CGPoint) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.touchPointMain
            }
            return .zero
        })
    }
    public static var touchUV: CGPoint {
        CGPoint(x: .touchU, y: .touchV)
    }
//    public static var touchPoints: [CGPoint] {
//        var points: [CGPoint] = []
//        for i in 0..<10 {
//            let point = CGPoint({ () -> (CGPoint) in
//                for pix in Live.main.linkedPixs {
//                    guard pix.view.superview != nil else { continue }
//                    let touchPoints = pix.view.liveTouchView.touchPoints
//                    guard touchPoints.count > i else { continue }
//                    return touchPoints[i]
//                }
//                return .zero
//            })
//            points.append(point)
//        }
//        return points
//    }
    #elseif os(macOS)
    public static var mouseXYAbs: CGPoint {
        return CGPoint({ () -> (CGPoint) in
            return NSEvent.mouseLocation
        })
    }
    public static var mouseXY: CGPoint {
        return CGPoint({ () -> (CGPoint) in
            for linkedPix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard linkedPix.view.superview != nil else { continue }
                if let mousePoint = linkedPix.pixView.liveMouseView.mousePoint {
                    return mousePoint
                }
            }
            return .zero
        })
    }
    #endif
    
    // MARK: - Corners

    public static func topLeft(resolution: Resolution) -> CGPoint {
        return CGPoint(x: -resolution.aspect / 2.0, y: 0.5)
    }
    public static func topRight(resolution: Resolution) -> CGPoint {
        return CGPoint(x: resolution.aspect / 2.0, y: 0.5)
    }
    public static func bottomLeft(resolution: Resolution) -> CGPoint {
        return CGPoint(x: -resolution.aspect / 2.0, y: -0.5)
    }
    public static func bottomRight(resolution: Resolution) -> CGPoint {
        return CGPoint(x: resolution.aspect / 2.0, y: -0.5)
    }
    
}

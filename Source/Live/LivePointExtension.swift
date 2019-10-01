//
//  LivePointExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Live

extension LivePoint {
    
    // MARK: - Touch / Mouse
    
    #if os(iOS)
    public static var touchXY: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                return pix.view.liveTouchView.touchPointMain
            }
            return .zero
        })
    }
//    public static var touchPoints: [LivePoint] {
//        var points: [LivePoint] = []
//        for i in 0..<10 {
//            let point = LivePoint({ () -> (CGPoint) in
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
    public static var mouseXYAbs: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            return NSEvent.mouseLocation
        })
    }
    public static var mouseXY: LivePoint {
        return LivePoint({ () -> (CGPoint) in
            for linkedPix in PixelKit.main.linkedPixs {
                guard linkedPix.view.superview != nil else { continue }
                if let mousePoint = linkedPix.view.liveMouseView.mousePoint {
                    return mousePoint
                }
            }
            return .zero
        })
    }
    #endif
    
    // MARK: - Corners

    public static func topLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: -res.aspect / 2.0, y: 0.5)
    }
    public static func topRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: res.aspect / 2.0, y: 0.5)
    }
    public static func bottomLeft(res: PIX.Res) -> LivePoint {
        return LivePoint(x: -res.aspect / 2.0, y: -0.5)
    }
    public static func bottomRight(res: PIX.Res) -> LivePoint {
        return LivePoint(x: res.aspect / 2.0, y: -0.5)
    }
    
}

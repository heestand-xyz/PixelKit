//
//  CGFloatExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics
import LiveValues
import RenderKit

extension CGFloat {
    
    // MARK: - Live Final
    
    public static var liveFinal: CGFloat {
        var value: CGFloat = 0.0
        var lastFrame: Int = -1
        return CGFloat({ () -> (CGFloat) in
            guard lastFrame != PixelKit.main.render.finalFrame else {
                lastFrame = PixelKit.main.render.finalFrame
                return value
            }
//            if !self.live.isFrozen {
            value += 1.0 / CGFloat(PixelKit.main.render.finalFps ?? PixelKit.main.render.fpsMax)
//            }
            lastFrame = PixelKit.main.render.finalFrame
            return value
        })
    }
    
    // MARK: - Touch / Mouse

    #if os(iOS)
    public static var touch: CGFloat {
        return CGFloat({ () -> (CGFloat) in
            return Bool(LiveBool.touch) ? 1.0 : 0.0
        })
    }
    public static var touchX: CGFloat {
        return CGFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.touchPointMain.x
            }
            return 0.0
        })
    }
    public static var touchY: CGFloat {
        return CGFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.touchPointMain.y
            }
            return 0.0
        })
    }
    public static var touchU: CGFloat {
        var aspect: CGFloat = 1.0
        for pix in PixelKit.main.render.linkedNodes as! [PIX] {
            guard pix.view.superview != nil else { continue }
            aspect = pix.renderResolution.aspect
            break
        }
        return touchX / aspect + 0.5
    }
    public static var touchV: CGFloat {
        return touchY + 0.5
    }
    public static var touchForce: CGFloat {
        return CGFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.force
            }
            return 0.0
        })
    }
    #elseif os(macOS)
    public static var mouseLeft: CGFloat {
        return LiveBool.mouseLeft <?> 1.0 <=> 0.0
    }
    public static var mouseRight: CGFloat {
        return LiveBool.mouseRight <?> 1.0 <=> 0.0
    }
    public static var mouseInView: CGFloat {
        return LiveBool.mouseInView <?> 1.0 <=> 0.0
    }
    public static var mouseX: CGFloat {
        return CGPoint.mouseXY.x
    }
    public static var mouseY: CGFloat {
        return CGPoint.mouseXY.y
    }
    #endif
    
}

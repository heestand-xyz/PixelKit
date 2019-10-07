//
//  LiveFloatExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

extension LiveFloat {
    
    // MARK: - Live Final
    
    public static var liveFinal: LiveFloat {
        var value: CGFloat = 0.0
        var lastFrame: Int = -1
        return LiveFloat({ () -> (CGFloat) in
            guard lastFrame != PixelKit.main.render.finalFrame else {
                lastFrame = PixelKit.main.render.finalFrame
                return value
            }
            if !self.live.isFrozen {
                value += 1.0 / CGFloat(PixelKit.main.render.finalFps ?? PixelKit.main.render.fpsMax)
            }
            lastFrame = PixelKit.main.render.finalFrame
            return value
        })
    }
    
    // MARK: - Touch / Mouse

    #if os(iOS)
    public static var touch: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return Bool(LiveBool.touch) ? 1.0 : 0.0
        })
    }
    public static var touchX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.touchPointMain.x
            }
            return 0.0
        })
    }
    public static var touchY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.touchPointMain.y
            }
            return 0.0
        })
    }
    public static var touchU: LiveFloat {
        var aspect: LiveFloat = 1.0
        for pix in PixelKit.main.render.linkedNodes as! [PIX] {
            guard pix.view.superview != nil else { continue }
            aspect = pix.renderResolution.aspect
            break
        }
        return touchX / aspect + 0.5
    }
    public static var touchV: LiveFloat {
        return touchY + 0.5
    }
    public static var touchForce: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.render.linkedNodes as! [PIX] {
                guard pix.view.superview != nil else { continue }
                return pix.pixView.liveTouchView.force
            }
            return 0.0
        })
    }
    #elseif os(macOS)
    public static var mouseLeft: LiveFloat {
        return LiveBool.mouseLeft <?> 1.0 <=> 0.0
    }
    public static var mouseRight: LiveFloat {
        return LiveBool.mouseRight <?> 1.0 <=> 0.0
    }
    public static var mouseInView: LiveFloat {
        return LiveBool.mouseInView <?> 1.0 <=> 0.0
    }
    public static var mouseX: LiveFloat {
        return LivePoint.mouseXY.x
    }
    public static var mouseY: LiveFloat {
        return LivePoint.mouseXY.y
    }
    #endif
    
}

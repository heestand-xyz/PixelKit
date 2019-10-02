//
//  LiveBoolExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues

extension LiveBool {

    #if os(iOS)
    public static var touch: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveTouchView.touch {
                    return true
                }
            }
            return false
        })
    }
    #elseif os(macOS)
    public static var mouseLeft: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseLeft {
                    return true
                }
            }
            return false
        })
    }
    public static var mouseRight: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseRight {
                    return true
                }
            }
            return false
        })
    }
    public static var mouseInView: LiveBool {
        return LiveBool({ () -> (Bool) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                if pix.view.liveMouseView.mouseInView {
                    return true
                }
            }
            return false
        })
    }
    #endif
    
}

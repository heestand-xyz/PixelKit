//
//  LiveColorExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

extension LiveColor {
    
    // MARK: - Touch / Mouse
        
    #if os(iOS)
    public static var touch: LiveColor {
        return LiveColor(lum: .touch)
    }
    #elseif os(macOS)
    public static var mouseLeft: LiveColor {
        return LiveBool.mouseLeft <?> .white <=> .black
    }
    public static var mouseRight: LiveColor {
        return LiveBool.mouseRight <?> .white <=> .black
    }
    public static var mouseInView: LiveColor {
        return LiveBool.mouseInView <?> .white <=> .black
    }
    #endif
    
}

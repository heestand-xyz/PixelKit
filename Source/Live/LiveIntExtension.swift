//
//  LiveIntExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

extension LiveInt {
    
    // MARK: - Touch
    
    #if os(iOS)
    public static var touch: LiveInt {
        return LiveInt({ () -> (Int) in
            return Bool(LiveBool.touch) ? 1 : 0
        })
    }
    #endif
    
}

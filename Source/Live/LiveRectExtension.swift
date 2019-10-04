//
//  LiveRectExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

extension LiveRect {
    
    public static func fill(resolution: Resolution) -> LiveRect {
        return LiveRect.fill(aspect: resolution.aspect)
    }
    
}

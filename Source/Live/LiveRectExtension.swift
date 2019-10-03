//
//  LiveRectExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues

extension LiveRect {
    
    public static func fill(res: Resolution) -> LiveRect {
        return LiveRect.fill(aspect: res.aspect)
    }
    
}

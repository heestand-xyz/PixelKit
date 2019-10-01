//
//  LiveRectExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Live

extension LiveRect {
    
    public static func fill(res: PIX.Res) -> LiveRect {
        return LiveRect.fill(aspect: res.aspect)
    }
    
}

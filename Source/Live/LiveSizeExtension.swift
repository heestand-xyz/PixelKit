//
//  LiveSizeExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

extension LiveSize {
    
    public static func fill(resolution: Resolution) -> LiveSize {
        return LiveSize.fill(aspect: resolution.aspect)
    }
    
}

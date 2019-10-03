//
//  LiveSizeExtension.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues

extension LiveSize {
    
    public static func fill(res: Resolution) -> LiveSize {
        return LiveSize.fill(aspect: res.aspect)
    }
    
}

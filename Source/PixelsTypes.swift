//
//  PixelsTypes.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-28.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension Pixels {
    
    public struct Pixel {
        public let x: Int
        public let y: Int
        public let uv: CGVector
        public let color: LiveColor
    }
    
}

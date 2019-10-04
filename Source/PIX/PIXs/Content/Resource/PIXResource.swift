//
//  PIXResource.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import RenderKit
import CoreVideo

open class PIXResource: PIXContent, NODEResource {
    
    public var pixelBuffer: CVPixelBuffer?
    var flop: Bool = false
    
}

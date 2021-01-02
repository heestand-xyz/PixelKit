//
//  PIXResource.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-16.
//  Open Source - MIT License
//

import RenderKit
import CoreVideo

open class PIXResource: PIXContent, NODEResource {
    
    public var pixelBuffer: CVPixelBuffer?
    var flop: Bool = false
    
    override func clearRender() {
        pixelBuffer = nil
        super.clearRender()
    }
    
}

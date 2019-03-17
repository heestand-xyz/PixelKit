//
//  PixelsProtocols.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import Metal

public protocol PixelsDelegate: class {
    func pixelsFrameLoop()
}

public protocol PixelsCustomRenderDelegate {
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture?
}

public protocol PixelsCustomMergerRenderDelegate {
    func customRender(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> (a: MTLTexture?, b: MTLTexture?)
}

public protocol PixelsCustomGeometryDelegate {
    func customVertices() -> Pixels.Vertices?
}

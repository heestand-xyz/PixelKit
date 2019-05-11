//
//  PixelKitProtocols.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import Metal

public protocol PixelDelegate: class {
    func pixelFrameLoop()
}

public protocol PixelCustomRenderDelegate {
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture?
}

public protocol PixelCustomMergerRenderDelegate {
    func customRender(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture?
}

public protocol PixelCustomGeometryDelegate {
    func customVertices() -> PixelKit.Vertices?
}

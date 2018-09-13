//
//  PixelsProtocols.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Metal

public protocol PixelsDelegate: class {
    func pixelsFrameLoop()
}

public protocol PixelsCustomRenderDelegate {
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture?
}

public protocol PixelsCustomGeometryDelegate {
    func customVertecies() -> Pixels.Vertecies?
}

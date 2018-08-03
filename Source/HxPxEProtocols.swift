//
//  HxPxEProtocols.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public protocol HxPxEDelegate {
    func hxpxeFrameLoop()
}

protocol CustomRenderDelegate {
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture?
}

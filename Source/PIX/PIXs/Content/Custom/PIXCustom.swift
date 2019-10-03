//
//  PIXCustom.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import Metal

open class PIXCustom: PIXContent, PIXRes, PixelCustomRenderDelegate {
    
    override open var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Public Properties
    
    public var res: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    
    public var bgColor: LiveColor = .black
    
    override open var liveValues: [LiveValue] { return [bgColor] }
    
    required public init(res: Resolution = .auto) {
        self.res = res
        super.init()
        customRenderDelegate = self
        customRenderActive = true
        applyResolution { self.setNeedsRender() }
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? { return nil }
    
}

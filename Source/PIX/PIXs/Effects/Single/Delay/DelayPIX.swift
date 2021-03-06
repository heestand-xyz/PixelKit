//
//  DelayPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-23.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import RenderKit
import Resolution
import Metal

final public class DelayPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var cachedTextures: [MTLTexture] = []
    
    // MARK: - Public Properties
    
    @LiveInt("delayFrames", range: 0...60) public var delayFrames: Int = 10
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_delayFrames]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Delay", typeName: "pix-effect-single-delay")
        setup()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        setup()
    }
    
    func setup() {
        customRenderActive = true
        customRenderDelegate = self
        PixelKit.main.render.listenToFrames { [weak self] in
            guard let self = self else { return }
            guard !self.destroyed else { return }
            guard self.connectedIn else { return }
            self.render()
        }
    }
    
    // MARK: Delay
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if cachedTextures.count > 0 {
            cachedTextures.remove(at: 0)
        }
        if let textureCopy = try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue) {
            while delayFrames != cachedTextures.count {
                if cachedTextures.count < delayFrames {
                    cachedTextures.append(textureCopy)
                } else {
                    cachedTextures.remove(at: 0)
                }
            }
        }
        return cachedTextures.first ?? texture
    }
    
}

public extension NODEOut {
    
    func pixDelay(frames: Int) -> DelayPIX {
        let delayPix = DelayPIX()
        delayPix.name = ":delay:"
        delayPix.input = self as? PIX & NODEOut
        delayPix.delayFrames = frames
        return delayPix
    }
    
}

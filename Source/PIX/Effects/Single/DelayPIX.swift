//
//  DelayPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-09-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Metal

public class DelayPIX: PIXSingleEffect, PixelsCustomRenderDelegate {
    
    override open var shader: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
//    public var delaySeconds: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var delayFrames: Int = 1 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum EdgeCodingKeys: String, CodingKey {
        case delayFrames
    }
    
    var cachedTextures: [MTLTexture] = []
    
    public override required init() {
        super.init()
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        delayFrames = try container.decode(Int.self, forKey: .delayFrames)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(delayFrames, forKey: .delayFrames)
    }
    
    // MARK: Delay
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard delayFrames > 0 else { return texture }
        cachedTextures.append(texture)
        if cachedTextures.count > delayFrames {
            cachedTextures.remove(at: 0)
        }
        return cachedTextures.first!
    }
    
}

public extension PIXOut {
    
    func _delay(frames: Int) -> DelayPIX {
        let delayPix = DelayPIX()
        delayPix.name = ":delay:"
        delayPix.inPix = self as? PIX & PIXOut
        delayPix.delayFrames = frames
        return delayPix
    }
    
}

//
//  TimeMachinePIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-03-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Metal

public class TimeMachinePIX: PIXMergerEffect, PixelsCustomMergerRenderDelegate {
   
    override open var shader: String { return "effectMergerTimeMachinePIX" }
    
    // MARK: - Public Properties
    
    public var seconds: LiveFloat = 1.0
    
    // MARK: - Private Properties
    
    struct CachedTexture {
        let texture: MTLTexture
        let date: Date
    }
    var textureCache: [CachedTexture] = []
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [seconds]
    }
    
    // MARK: - Life Cycle
    
    public override required init() {
        super.init()
        customMergerRenderActive = true
        customMergerRenderDelegate = self
        Pixels.main.listenToFrames { () -> (Bool) in
            self.frameLoop()
            return true
        }
    }
    
    // MARK: - Frame Loop
    
    func frameLoop() {

        var textures: [MTLTexture] = []
        for (i, cached) in self.textureCache.enumerated() {
            let relDelay = cached.date.timeIntervalSinceNow + seconds.double
            if relDelay >= 0 {
                textures.append(cached.texture)
            } else {
                var i = i
                if i == 0 {
                    textures.append(cached.texture)
                    i = 1
                }
                self.textureCache.removeSubrange(i..<self.textureCache.count)
                break
            }
        }

//        if !textures.isEmpty {
//            if connectedIn {
//                let lum_tex = (self.second_connected_in_node_extra!.output_node as! PIXNode).metal_base!.metal_view!.last_drawn_texture!
//                self.metal_base!.metal_view!.secondInputTexture = lum_tex
//                self.metal_base!.metal_view!.timeMachineInputTextures = textures
//                self.metal_base!.metal_view!.setNeedsDisplay()
//            }
//        }
        
    }
    
    // MARK: - Custom Merger Render Delegate
    
    public func customRender(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> (a: MTLTexture?, b: MTLTexture?) {
    
        textureCache.insert(CachedTexture(texture: textureB, date: Date()), at: 0)
    
        return (a: textureA, b: textureB)
    }
    
}

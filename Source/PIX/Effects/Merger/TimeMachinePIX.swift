//
//  TimeMachinePIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-03-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Metal

public class TimeMachinePIX: PIXMergerEffect {
   
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
//        customMergerRenderActive = true
//        customMergerRenderDelegate = self
        Pixels.main.listenToFrames { () -> (Bool) in
            self.frameLoop()
            return true
        }
    }
    
    // MARK: - Frame Loop
    
    func frameLoop() {

//        var textures: [MTLTexture] = []
//        for (i, cached) in self.textureCache.enumerated() {
//            let relDelay = cached.date.timeIntervalSinceNow + seconds.double
//            if relDelay >= 0 {
//                textures.append(cached.texture)
//            } else {
//                var i = i
//                if i == 0 {
//                    textures.append(cached.texture)
//                    i = 1
//                }
//                self.textureCache.removeSubrange(i..<self.textureCache.count)
//                break
//            }
//        }
        
        let count = textureCache.count
        for i in 0..<count {
            let ir = count - i - 1
            if -textureCache[ir].date.timeIntervalSinceNow > Double(seconds.uniform) {
                textureCache.remove(at: ir)
            }
        }
        
    }
    
    // MARK: - Custom Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> [MTLTexture] {
        textureCache.insert(CachedTexture(texture: texture, date: Date()), at: 0)
        return textureCache.map({$0.texture})
    }
    
    // FIXME: Dissconnect: Empty array
    
}

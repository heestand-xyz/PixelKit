//
//  TimeMachinePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-03-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//


import Metal

public class TimeMachinePIX: PIXMergerEffect {
   
    override open var shader: String { return "effectMergerTimeMachinePIX" }
    
    // MARK: - Public Properties
    
    public var seconds: LiveFloat = LiveFloat(1.0, max: 10.0)
    
    // MARK: - Private Properties
    
    struct CachedTexture {
        let texture: MTLTexture
        let date: Date
    }
    var textureCache: [CachedTexture] = []
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [seconds]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "timeMachine"
//        customMergerRenderActive = true
//        customMergerRenderDelegate = self
        PixelKit.main.listenToFrames {
            self.frameLoop()
            self.setNeedsRender()
        }
    }
    
    // MARK: - Frame Loop
    
    func frameLoop() {
        
        if let firstCachedTexture = textureCache.first {
            if -firstCachedTexture.date.timeIntervalSinceNow > (1.0 / Double(PixelKit.main.fps)) {
                let newCachedTexture = CachedTexture(texture: firstCachedTexture.texture, date: Date())
                textureCache.insert(newCachedTexture, at: 0)
            }
        }
        
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
        if let textureCopy = try? pixelKit.copy(texture: texture) {
            textureCache.insert(CachedTexture(texture: textureCopy, date: Date()), at: 0)
        }
        return textureCache.map({$0.texture})
    }
    
    // FIXME: Dissconnect: Empty array
    
}

//
//  TimeMachinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-16.
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

final public class TimeMachinePIX: PIXMergerEffect, PIXViewable {
   
    override public var shaderName: String { return "effectMergerTimeMachinePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("seconds", range: 0.0...2.0) public var seconds: CGFloat = 1.0
    
    // MARK: - Private Properties
    
    struct CachedTexture {
        let texture: MTLTexture
        let date: Date
    }
    var textureCache: [CachedTexture] = []
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_seconds] + super.liveList
    }
    
    override public var values: [Floatable] {
        [seconds]
    }
    
    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Time Machine", typeName: "pix-effect-merger-time-machine")
        setup()
    }
    
    func setup() {
        PixelKit.main.render.listenToFrames { [weak self] in
            guard let self = self else { return }
            self.frameLoop()
            self.render()
        }
    }
    
    // MARK: - Frame Loop
    
    func frameLoop() {
        
        if let firstCachedTexture = textureCache.first {
            if -firstCachedTexture.date.timeIntervalSinceNow > (1.0 / Double(PixelKit.main.render.fps)) {
                let newCachedTexture = CachedTexture(texture: firstCachedTexture.texture, date: Date())
                textureCache.insert(newCachedTexture, at: 0)
            }
        }
        
        let count = textureCache.count
        for i in 0..<count {
            let ir = count - i - 1
            if -textureCache[ir].date.timeIntervalSinceNow > Double(seconds) {
                textureCache.remove(at: ir)
            }
        }
        
    }
    
    // MARK: - Custom Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> [MTLTexture] {
        if let textureCopy = try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue) {
            textureCache.insert(CachedTexture(texture: textureCopy, date: Date()), at: 0)
        }
        return textureCache.map({$0.texture})
    }
    
    // FIXME: Dissconnect: Empty array
    
}

public extension NODEOut {
    
    func pixTimeMachine(seconds: CGFloat = 1.0, pix: () -> (PIX & NODEOut)) -> TimeMachinePIX {
        pixTimeMachine(pix: pix(), seconds: seconds)
    }
    func pixTimeMachine(pix: PIX & NODEOut, seconds: CGFloat = 1.0) -> TimeMachinePIX {
        let timeMachinePix = TimeMachinePIX()
        timeMachinePix.name = ":timeMachine:"
        timeMachinePix.inputA = self as? PIX & NODEOut
        timeMachinePix.inputB = pix
        timeMachinePix.seconds = seconds
        return timeMachinePix
    }
    
}

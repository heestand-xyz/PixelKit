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
    
    public typealias Model = TimeMachinePixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
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
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    public override func destroy() {
        super.destroy()
        
        textureCache = []
    }
    
    // MARK: - Setup
    
    private func setup() {
        PixelKit.main.render.listenToFrames { [weak self] in
            guard let self = self else { return }
            self.frameLoop()
            self.render()
        }
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        seconds = model.seconds

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.seconds = seconds

        super.liveUpdateModelDone()
    }
    
    // MARK: - Frame Loop
    
    private func frameLoop() {
        
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
        if let textureCopy = try? Texture.copy(texture: texture, on: PixelKit.main.render.metalDevice, in: PixelKit.main.render.commandQueue) {
            textureCache.insert(CachedTexture(texture: textureCopy, date: Date()), at: 0)
        }
        return textureCache.map({$0.texture})
    }
    
    // MARK: - Connection
    
    public override func didDisconnect() {
        super.didDisconnect()
        
        textureCache = []
    }
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

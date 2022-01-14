//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-21.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

final public class FeedbackPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = FeedbackPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var readyToFeed: Bool { texture != nil && feedbackInput?.texture != nil }
    /// Calling `clearFeed()` will turn `feedActive` to `false` for `n` amount of frames.
    public var clearFrameCount: Int = 5
    var clearFrame: Int = 0
    var clearingFeed: Bool { clearFrame > 0 }

    // MARK: - Public Properties
    
    var feedTexture: MTLTexture? {
        guard let texture = feedbackInput?.texture else { return nil }
        return try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
    }
    
    @LiveBool("feedActive") public var feedActive: Bool = true
    
    @available(*, deprecated, renamed: "feedbackInput")
    public var feedPix: (PIX & NODEOut)? {
        get { feedbackInput }
        set { feedbackInput = newValue }
    }
    public var feedbackInput: (PIX & NODEOut)? { didSet { if feedActive { render() } } }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_feedActive]
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
    
    // MARK: - Setup
    
    func setup() {
        pixelKit.render.listenToFramesUntil { [weak self] in
            guard let self = self else { return .done }
            if self.input?.texture != nil && self.feedTexture != nil {
                self.render()
                return .done
            } else {
                return .continue
            }
        }
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Feedback
    
    func tileFeedTexture(at tileIndex: TileIndex) -> MTLTexture? {
        guard let tileFeedPix = feedbackInput as? PIX & NODETileable2D else {
            pixelKit.logger.log(node: self, .error, .texture, "Feed Input PIX Not Tileable.")
            return nil
        }
        guard let texture = tileFeedPix.tileTextures?[tileIndex.y][tileIndex.x] else { return nil }
        return try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
    }
    
    override public func didRender(renderPack: RenderPack) {
        super.didRender(renderPack: renderPack)
        if clearingFeed {
            if clearFrame >= clearFrameCount {
                pixelKit.logger.log(node: self, .info, .effect, "Did Clear Feedback")
                feedActive = true
                clearFrame = 0
            } else {
                clearFrame += 1
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.render()
        }
    }
    
    @available(*, deprecated, renamed: "clearFeed")
    public func resetFeed() {
        clearFeed()
    }
    
    public func clearFeed() {
        guard !clearingFeed else { return }
        guard feedActive else {
            pixelKit.logger.log(node: self, .info, .effect, "Feedback Clear Canceled - Not Active.")
            return
        }
        pixelKit.logger.log(node: self, .info, .effect, "Will Clear Feedback")
        feedActive = false
        clearFrame = 1
        render()
    }
    
}

public extension NODEOut {
    
    func pixFeedback(_ fraction: CGFloat = 1.0, loop: ((FeedbackPIX) -> (PIX & NODEOut))? = nil) -> FeedbackPIX {
        let feedbackPix = FeedbackPIX()
        feedbackPix.name = "feed:feedback"
        feedbackPix.input = self as? PIX & NODEOut
        let crossPix = CrossPIX()
        crossPix.name = "feed:cross"
        crossPix.inputA = self as? PIX & NODEOut
        crossPix.inputB = loop?(feedbackPix) ?? feedbackPix
        crossPix.fraction = fraction
        feedbackPix.feedbackInput = crossPix
        return feedbackPix
    }
    
}

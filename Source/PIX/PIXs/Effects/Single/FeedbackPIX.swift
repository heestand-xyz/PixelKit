//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-21.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Metal

final public class FeedbackPIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "nilPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Private Properties
    
    var readyToFeed: Bool = false
    /// Calling `clearFeed()` will turn `feedActive` to `false` for `n` amount of frames.
    public var clearFrameCount: Int = 5
    var clearFrame: Int = 0
    var clearingFeed: Bool { clearFrame > 0 }

    // MARK: - Public Properties
    
    var feedTexture: MTLTexture? {
        guard let texture = feedPix?.texture else { return nil }
        return try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
    }
    
    @Live public var feedActive: Bool = true
    public var feedPix: (PIX & NODEOut)? { didSet { if feedActive { setNeedsRender() } } }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_feedActive]
    }
    
    // MARK: - Life Cycle

    public required init() {
        super.init(name: "Feedback", typeName: "pix-effect-single-feedback")
        pixelKit.render.listenToFramesUntil {
            if self.input?.texture != nil && self.feedTexture != nil {
                self.setNeedsRender()
                return .done
            } else {
                return .continue
            }
        }
    }
    
    func tileFeedTexture(at tileIndex: TileIndex) -> MTLTexture? {
        guard let tileFeedPix = feedPix as? PIX & NODETileable2D else {
            pixelKit.logger.log(node: self, .error, .texture, "Feed Input PIX Not Tileable.")
            return nil
        }
        guard let texture = tileFeedPix.tileTextures?[tileIndex.y][tileIndex.x] else { return nil }
        return try? Texture.copy(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
    }
    
    override public func didRender(texture: MTLTexture, force: Bool) {
        super.didRender(texture: texture)
        if clearingFeed {
            if clearFrame >= clearFrameCount {
                pixelKit.logger.log(node: self, .info, .effect, "Did Clear Feedback")
                feedActive = true
                clearFrame = 0
            } else {
                clearFrame += 1
            }
        }
        readyToFeed = true
        DispatchQueue.main.async {
            self.setNeedsRender()
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
        setNeedsRender()
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
        feedbackPix.feedPix = crossPix
        return feedbackPix
    }
    
}

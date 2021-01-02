//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-21.
//  Open Source - MIT License
//


import RenderKit
import Metal

public class FeedbackPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
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
    
    public var feedActive: Bool = true { didSet { setNeedsRender() } }
    public var feedPix: (PIX & NODEOut)? { didSet { if feedActive { setNeedsRender() } } }
    
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
    
//    func willClearFeed() {
//        pixelKit.logger.log(node: self, .info, .effect, "Will Clear Feedback")
//        clearingFeed = false
//        DispatchQueue.main.async {
//            self.feedActive = true
//            self.setNeedsRender()
//            self.pixelKit.logger.log(node: self, .info, .effect, "Did Clear Feedback")
//        }
//    }
    
}

public extension NODEOut {
    
    func _feed(_ fraction: CGFloat = 1.0, loop: ((FeedbackPIX) -> (PIX & NODEOut))? = nil) -> FeedbackPIX {
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
    
//    func _feedAdd(loop: ((FeedbackPIX) -> (PIX & NODEOut))? = nil) -> FeedbackPIX {
//        let feedbackPix = FeedbackPIX()
//        feedbackPix.name = "feed:feedback"
//        let pix = self as! PIX & NODEOut
//        feedbackPix.input = pix
//        feedbackPix.feedPix = pix + (loop?(feedbackPix) ?? feedbackPix)
//        return feedbackPix
//    }
    
}

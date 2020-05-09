//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import Metal

public class FeedbackPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var readyToFeed: Bool = false
    var feedReset: Bool = false

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
        if feedReset {
            feedActive = true
            feedReset = false
        }
        readyToFeed = true
        setNeedsRender()
    }
    
    public func resetFeed() {
        guard feedActive else {
            pixelKit.logger.log(node: self, .info, .effect, "Feedback reset; feed not active.")
            return
        }
        feedActive = false
        feedReset = true
        setNeedsRender()
    }
    
}

public extension NODEOut {
    
    func _feed(_ fraction: LiveFloat = 1.0, loop: ((FeedbackPIX) -> (PIX & NODEOut))? = nil) -> FeedbackPIX {
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

//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

import LiveValues
import Metal

public class FeedbackPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var readyToFeed: Bool = false
    var feedReset: Bool = false

    // MARK: - Public Properties
    
    var feedTexture: MTLTexture? {
        guard let texture = feedPix?.texture else { return nil }
        return try? pixelKit.copy(texture: texture)
    }
    
    public var feedActive: Bool = true { didSet { setNeedsRender() } }
    public var feedPix: (PIX & NODEOut)? { didSet { if feedActive { setNeedsRender() } } }
    
    public required init() {
        super.init()
        name = "feedback"
        pixelKit.listenToFramesUntil { () -> (PixelKit.ListenState) in
            if self.inPix?.texture != nil && self.feedTexture != nil {
                self.setNeedsRender()
                return .done
            } else {
                return .continue
            }
        }
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
        feedbackPix.inPix = self as? PIX & NODEOut
        let crossPix = CrossPIX()
        crossPix.name = "feed:cross"
        crossPix.inPixA = self as? PIX & NODEOut
        crossPix.inPixB = loop?(feedbackPix) ?? feedbackPix
        crossPix.fraction = fraction
        feedbackPix.feedPix = crossPix
        return feedbackPix
    }
    
//    func _feedAdd(loop: ((FeedbackPIX) -> (PIX & NODEOut))? = nil) -> FeedbackPIX {
//        let feedbackPix = FeedbackPIX()
//        feedbackPix.name = "feed:feedback"
//        let pix = self as! PIX & NODEOut
//        feedbackPix.inPix = pix
//        feedbackPix.feedPix = pix + (loop?(feedbackPix) ?? feedbackPix)
//        return feedbackPix
//    }
    
}

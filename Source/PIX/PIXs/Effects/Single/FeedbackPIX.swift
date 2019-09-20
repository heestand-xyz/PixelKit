//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//


import Metal

public class FeedbackPIX: PIXSingleEffect {
    
    override open var shader: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var readyToFeed: Bool = false
    var feedReset: Bool = false

    // MARK: - Public Properties
    
    var feedTexture: MTLTexture? {
        guard let texture = feedPix?.texture else { return nil }
        return try? pixelKit.copy(texture: texture)
    }
    
    public var feedActive: Bool = true { didSet { setNeedsRender() } }
    public var feedPix: (PIX & PIXOut)? { didSet { if feedActive { setNeedsRender() } } }
    
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
            pixelKit.log(pix: self, .info, .effect, "Feedback reset; feed not active.")
            return
        }
        feedActive = false
        feedReset = true
        setNeedsRender()
    }
    
}

public extension PIXOut {
    
    func _feed(_ fraction: LiveFloat = 1.0, loop: ((FeedbackPIX) -> (PIX & PIXOut))? = nil) -> FeedbackPIX {
        let feedbackPix = FeedbackPIX()
        feedbackPix.name = "feed:feedback"
        feedbackPix.inPix = self as? PIX & PIXOut
        let crossPix = CrossPIX()
        crossPix.name = "feed:cross"
        crossPix.inPixA = self as? PIX & PIXOut
        crossPix.inPixB = loop?(feedbackPix) ?? feedbackPix
        crossPix.fraction = fraction
        feedbackPix.feedPix = crossPix
        return feedbackPix
    }
    
//    func _feedAdd(loop: ((FeedbackPIX) -> (PIX & PIXOut))? = nil) -> FeedbackPIX {
//        let feedbackPix = FeedbackPIX()
//        feedbackPix.name = "feed:feedback"
//        let pix = self as! PIX & PIXOut
//        feedbackPix.inPix = pix
//        feedbackPix.feedPix = pix + (loop?(feedbackPix) ?? feedbackPix)
//        return feedbackPix
//    }
    
}

//
//  FeedbackPIX.swift
//  Pixels
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
        return feedPix?.texture
    }
    
    public var feedActive: Bool = true { didSet { setNeedsRender() } }
    public var feedPix: (PIX & PIXOut)? { didSet { if feedActive { setNeedsRender() } } }
    
    public override required init() {
        super.init()
//        pixels.delay(frames: 10, done: {
//            self.setNeedsRender()
//        })
    }
    
    override public func didRender(texture: MTLTexture, force: Bool) {
        super.didRender(texture: texture)
        if feedReset {
            feedActive = true
            feedReset = false
        }
        readyToFeed = true
        setNeedsRender()
//        switch pixels.renderMode {
//        case .frameLoop:
//            setNeedsRender()
//        case .direct:
        
//        }
    }
    
    public func resetFeed() {
        guard feedActive else {
            pixels.log(pix: self, .info, .effect, "Feedback reset; feed not active.")
            return
        }
        feedActive = false
        feedReset = true
        setNeedsRender()
    }
    
}

public extension PIXOut {
    
    func _feed(_ fraction: LiveFloat, loop: ((FeedbackPIX) -> (PIX & PIXOut))? = nil) -> FeedbackPIX {
        let feedbackPix = FeedbackPIX()
        feedbackPix.name = "feed:feedback"
        feedbackPix.inPix = self as? PIX & PIXOut
        let crossPix = CrossPIX()
        crossPix.name = "feed:cross"
        crossPix.inPixA = loop?(feedbackPix) ?? feedbackPix
        crossPix.inPixB = self as? PIX & PIXOut
        crossPix.fraction = fraction
        feedbackPix.feedPix = crossPix
        return feedbackPix
    }
    
    func _feedAdd(loop: ((FeedbackPIX) -> (PIX & PIXOut))? = nil) -> FeedbackPIX {
        let feedbackPix = FeedbackPIX()
        feedbackPix.name = "feed:feedback"
        let pix = self as! PIX & PIXOut
        feedbackPix.inPix = pix
        feedbackPix.feedPix = pix + (loop?(feedbackPix) ?? feedbackPix)
        return feedbackPix
    }
    
}

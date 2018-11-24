//
//  FeedbackPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-21.
//  Copyright © 2018 Hexagons. All rights reserved.
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
//            pixels.delay(frames: 1, done: {
//                self.setNeedsRender()
//            })
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
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

public extension PIXOut {
    
//    func _feed(loop: (FeedbackPIX) -> (PIX & PIXOut)) -> FeedbackPIX {
//        let feedbackPix = FeedbackPIX()
//        feedbackPix.inPix = self as? PIX & PIXOut
//        feedbackPix.feedPix = loop(feedbackPix)
//        return feedbackPix
//    }
    
    func _feed(_ fraction: CGFloat, loop: ((FeedbackPIX) -> (PIX & PIXOut))? = nil) -> FeedbackPIX {
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
    
}

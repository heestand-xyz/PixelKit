//
//  FeedbackPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

#if os(iOS)
import MetalPerformanceShadersProxy
#elseif os(macOS)
import Metal
#endif

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
//        pixelKit.delay(frames: 10, done: {
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
//        RunLoop.current.add(Timer(timeInterval: 2.0 / Double(pixelKit._fps), repeats: false, block: { t in
            self.setNeedsRender()
//        }), forMode: .common)
//        switch pixelKit.renderMode {
//        case .frameLoop:
//            setNeedsRender()
//        case .direct:
        
//        }
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

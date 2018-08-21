//
//  FeedbackPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-21.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class FeedbackPIX: PIXSingleEffect, PIXofaKind {
    
    var kind: PIX.Kind = .feedback
    
    public var feedActive: Bool = true { didSet { setNeedsRender() } }
    public var feedPix: (PIX & PIXOut)? { didSet { if feedActive { setNeedsRender() } } }
    var readyToFeed: Bool = false
    var feedReset: Bool = false

    public override required init() {
        super.init()
    }
    
    override func didRender(texture: MTLTexture, force: Bool) {
        super.didRender(texture: texture)
        if feedReset {
            feedActive = true
            feedReset = false
        }
        readyToFeed = true
//        HxPxE.main.delay(frames: 2, done: {
//            self.setNeedsRender()
//        })
        setNeedsRender()
    }
    
    public func resetFeed() {
        guard feedActive else {
            Logger.main.log(pix: self, .info, .effect, "Feedback reset; feed not active.")
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

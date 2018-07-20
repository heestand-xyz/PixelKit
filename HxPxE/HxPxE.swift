//
//  HxPxE.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class HxPxE {
    
    public var delegate: HxPxEDelegate?
    
    var displayLink: CADisplayLink?
    
    public init() {
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkCallback))
        displayLink!.add(to: RunLoop.main, forMode: .commonModes)
        
    }
    
    @objc func displayLinkCallback() {
        delegate?.hxpxeFrameLoop()
    }
    
}

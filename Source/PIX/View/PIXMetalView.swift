//
//  PIXMetalView.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

class PIXMetalView: MTKView {
    
    let pixels = Pixels.main
    
    var res: PIX.Res? {
        didSet {
            guard let res = res else { return }
            drawableSize = res.size
        }
    }
    
    var readyToRender: (() -> ())?
    
    public init() {
        
        let onePixelFrame = CGRect(x: 0, y: 0, width: 1, height: 1) // CHECK
        
        super.init(frame: onePixelFrame, device: pixels.metalDevice)
        
        colorPixelFormat = pixels.colorBits.mtl
        isOpaque = false
        framebufferOnly = false
        autoResizeDrawable = false
        enableSetNeedsDisplay = true
        isPaused = true
        
    }
    
    // MARK: Draw
    
    override public func draw(_ rect: CGRect) {
        autoreleasepool { // CHECK
            if rect.width > 0 && rect.height > 0 {
                if res != nil {
                    pixels.log(.info, .view, "Ready to Render.", loop: true)
                    readyToRender?()
                } else {
                    pixels.log(.warning, .view, "Draw: Resolution not set.", loop: true)
                }
            } else {
                pixels.log(.error, .view, "Draw: Rect is zero.", loop: true)
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

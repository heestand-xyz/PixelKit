//
//  PIXMetalView.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

import MetalKit

class PIXMetalView: MTKView {
    
    let pixelKit = PixelKit.main
    
    var res: PIX.Res? {
        didSet {
            guard let res = res else { return }
            drawableSize = res.size.cg
        }
    }
    
    var readyToRender: (() -> ())?
   
    // MARK: - Life Cycle
    
    public init() {
        
        let onePixelFrame = CGRect(x: 0, y: 0, width: 1, height: 1) // CHECK
        
        super.init(frame: onePixelFrame, device: pixelKit.metalDevice)
        
        colorPixelFormat = pixelKit.bits.mtl
        #if os(iOS) || os(tvOS)
        isOpaque = false
        #elseif os(macOS)
        layer!.isOpaque = false
        #endif
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
                    pixelKit.log(.detail, .view, "Ready to Render.", loop: true)
                    readyToRender?()
                } else {
                    pixelKit.log(.warning, .view, "Draw: Resolution not set.", loop: true)
                }
            } else {
                pixelKit.log(.error, .view, "Draw: Rect is zero.", loop: true)
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

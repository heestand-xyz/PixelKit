//
//  PIXMetalView.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

#if os(iOS) && targetEnvironment(simulator)
import MetalPerformanceShadersProxy
#else
import MetalKit
#endif

#if targetEnvironment(simulator)
import UIKit
class MTKView: UIView {
    var currentDrawable: CAMetalDrawable!
}
#endif

class PIXMetalView: MTKView {
    
    let pixelKit = PixelKit.main
    
    var res: PIX.Res? {
        didSet {
            guard let res = res else { return }
            #if !targetEnvironment(simulator)
            drawableSize = res.size.cg
            #endif
        }
    }
    
//    override var frame: CGRect {
//        didSet {
//            #if os(macOS)
//            setNeedsDisplay(frame)
//            #endif
//        }
//    }
    
    var readyToRender: (() -> ())?
   
    // MARK: - Life Cycle
    
    public init() {
        
        let onePixelFrame = CGRect(x: 0, y: 0, width: 1, height: 1) // CHECK
        
        #if !targetEnvironment(simulator)
        super.init(frame: onePixelFrame, device: pixelKit.metalDevice)
        #else
        super.init(frame: .zero)
        #endif
        
        #if !targetEnvironment(simulator)
        colorPixelFormat = pixelKit.bits.mtl
        #if os(iOS)
        isOpaque = false
        #elseif os(macOS)
        layer!.isOpaque = false
        #endif
        framebufferOnly = false
        autoResizeDrawable = false
        enableSetNeedsDisplay = true
        isPaused = true
        #endif
        
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

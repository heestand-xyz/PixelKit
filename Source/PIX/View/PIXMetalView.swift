//
//  PIXMetalView.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

class PIXMetalView: MTKView {
    
    var resolution: CGSize?
    
    var readyToRender: (() -> ())?
    
    public init() {
        
        super.init(frame: .zero, device: HxPxE.main.metalDevice)
        
        colorPixelFormat = HxPxE.main.colorBits.mtl
        isOpaque = false
        framebufferOnly = false
        autoResizeDrawable = false // CHECK
        contentMode = .scaleToFill //.scaleAspectFit
        enableSetNeedsDisplay = true
        isUserInteractionEnabled = false // CHECK
        contentScaleFactor = UIScreen.main.scale
        isPaused = true // CHECK
        
    }
    
    // MARK: Draw
    
    override public func draw(_ rect: CGRect) {
        autoreleasepool { // CHECK
            if rect.width > 0 && rect.height > 0 {
                if resolution != nil {
//                    print("HxPxE PIX is Ready to Render")
                    readyToRender?()
                } else {
//                    print("HxPxE WARNING:", "PIX Metal View:", "Draw:", "Resolution not set.")
                }
            } else {
                print("HxPxE ERROR:", "PIX Metal View:", "Draw:", "Rect is zero.")
            }
        }
    }
    
    func setResolution(_ newResolution: CGSize) {
        drawableSize = newResolution
        resolution = newResolution
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PIXView.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public class PIXView: MTKView {
    
    var resolution: CGSize?
    
//    override public var backgroundColor: UIColor? {
//        didSet {
//            if backgroundColor != nil {
//                let bgc = CIColor(color: backgroundColor!).components
//                clearColor = MTLClearColor(red: Double(bgc[0]), green: Double(bgc[1]), blue: Double(bgc[2]), alpha: Double(bgc[3]))
//            } else {
//                clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
//            }
//        }
//    }
    
    var readyToRender: (() -> ())?
//    var renderDone: (() -> ())?
    
    public init() {
        
        super.init(frame: .zero, device: HxPxE.main.metalDevice)
        
//        backgroundColor = .blue
        
        colorPixelFormat = HxPxE.main.bitMode.pixelFormat
        isOpaque = false
        framebufferOnly = false
        autoResizeDrawable = false // CHECK
        contentMode = .scaleToFill //.scaleAspectFit
        enableSetNeedsDisplay = true
        isUserInteractionEnabled = false // CHECK
        isPaused = true // CHECK
        
    }
    
    // MARK: Draw
    
    override public func draw(_ rect: CGRect) {
        autoreleasepool { // CHECK
            if rect.width > 0 && rect.height > 0 {
                if resolution != nil {                
//                    print("HxPxE - PIXView - Ready to Render")
                    readyToRender?()
                }
            } else {
                print("HxPxE ERROR:", "PIX View:", "Draw rect is zero.")
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setScaleFactor()
    }
    
    func setResolution(_ newResolution: CGSize) {
        drawableSize = newResolution
        resolution = newResolution
        setScaleFactor()
    }
    
    func setScaleFactor() {
        if resolution != nil {
            // CHECK auto bounds are not set on init...
//            let widthScale = resolution!.width / bounds.width
//            let heightScale = resolution!.height / bounds.height
            contentScaleFactor = 1 //UIScreen.main.scale //max(widthScale, heightScale) // CHECK
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

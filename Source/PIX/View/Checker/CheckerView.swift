//
//  CheckerView.swift
//  Pixels
//
//  Created by Hexagons on 2017-12-18.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class CheckerView: _View {
    
    #if os(iOS)
    let checker: UIImage
    #elseif os(macOS)
    let checker: NSImage
    #endif
    
    override var frame: CGRect {
        didSet {
            #if os(iOS)
            setNeedsDisplay()
            #elseif os(macOS)
            setNeedsDisplay(frame)
            #endif
        }
    }
    
    override init(frame: CGRect) {
        
        // FIXME: Generate the image on the fly.
        
        #if os(iOS)
        let bundle = Bundle(identifier: Pixels.main.kBundleId)
        checker = UIImage(named: "checker", in: bundle, compatibleWith: nil)!
        #elseif os(macOS)
//        let path = bundle?.pathForImageResource("checker")
        checker = NSImage(byReferencingFile: "checker.png")! //NSImage(named: "checker")!
        #endif
        
        super.init(frame: frame)
        
        #if os(iOS)
        isUserInteractionEnabled = false
        #endif
        
//        if let context = NSGraphicsContext.current?.cgContext {
//            context.saveGState();
//
//            context.setFillColor(NSColor.red.cgColor)
//
//            context.fill(CGRect(x: 50, y: 50, width: 50, height: 50))
////            let img = context.image { ctx in
////                ctx.cgContext.setFillColor(UIColor.red.cgColor)
////                ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
////                ctx.cgContext.setLineWidth(10)
////
////                let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
////                ctx.cgContext.addRect(rectangle)
////                ctx.cgContext.drawPath(using: .fillStroke)
////            }
//            context.restoreGState()
//
//            let img = NSImage(size: size)
//            img.addRepresentation(offscreenRep)
//
//            let x = NSImageView(image: img)
//            x.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            addSubview(x)
//
//        } else { assertionFailure() }
        
        let image = NSImage(size: CGSize(width: 64, height: 64))
        image.lockFocus()
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(PIX.Color.darkGray.cgColor)
        ctx.fill(CGRect(x: 25, y: 25, width: 25, height: 25))
        image.unlockFocus()
        
        let x = NSImageView(image: image)
        x.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        addSubview(x)
        
//        #if os(macOS)
//        wantsLayer = true
//        layer!.backgroundColor = NSColor.red.cgColor
//        #endif
        
    }
    
    override func draw(_ rect: CGRect) {
        
        #if os(iOS)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        #elseif os(macOS)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        #endif
        
        context.saveGState();
        
        let phase = CGSize(width: rect.width / 2, height: rect.height / 2)
        context.setPatternPhase(phase)
        
        #if os(iOS)
        let color = UIColor(patternImage: checker).cgColor
        #elseif os(macOS)
        let color = NSColor(patternImage: checker).cgColor
        #endif
        context.setFillColor(color)
        
        context.fill(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        
        context.restoreGState()
        
        super.draw(rect)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

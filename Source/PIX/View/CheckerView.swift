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
        
        super.init(frame: frame)
        
        #if os(iOS)
        isUserInteractionEnabled = false
        #endif
        
    }
    
    #if os(iOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    func checkerImage() -> _Image {
        let scale: CGFloat = 16
        #if os(iOS)
        return UIGraphicsImageRenderer(size: CGSize(width: scale * 2, height: scale * 2)).image { ctx in
            ctx.cgContext.setFillColor(LiveColor.lightGray.cgColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: 0, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: scale, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
            ctx.cgContext.setFillColor(LiveColor.darkGray.cgColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: scale, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: 0, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
        }
        #elseif os(macOS)
        let img = NSImage(size: CGSize(width: scale * 2, height: scale * 2))
        img.lockFocus()
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(LiveColor.darkGray.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: scale, width: scale, height: scale))
        ctx.setFillColor(LiveColor.lightGray.cgColor)
        ctx.fill(CGRect(x: 0, y: scale, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: 0, width: scale, height: scale))
        img.unlockFocus()
        return img
        #endif
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
        
        let checker = checkerImage()
        
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

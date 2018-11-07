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
        
        #if os(iOS)
        checker = UIImage(named: "checker", in: Bundle(identifier: Pixels.main.kBundleId), compatibleWith: nil)!
        #elseif os(macOS)
        checker = NSImage(named: "checker")!
        #endif
        
        super.init(frame: frame)
        
        #if os(iOS)
        isUserInteractionEnabled = false
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

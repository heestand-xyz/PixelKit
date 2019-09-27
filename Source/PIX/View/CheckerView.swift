//
//  CheckerView.swift
//  PixelKit
//
//  Created by Hexagons on 2017-12-18.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif


#if canImport(SwiftUI)
#if os(macOS)
@available(OSX 10.15, *)
public struct Checker: NSViewRepresentable {
    public init() {}
    public func makeNSView(context: Context) -> CheckerView {
        return CheckerView()
    }
    public func updateNSView(_ pixView: CheckerView, context: Context) {}
}
#else
@available(iOS 13.0.0, *)
@available(tvOS 13.0.0, *)
public struct Checker: UIViewRepresentable {
    public init() {}
    public func makeUIView(context: Context) -> CheckerView {
        return CheckerView()
    }
    public func updateUIView(_ pixView: CheckerView, context: Context) {}
}
#endif
#endif

public class CheckerView: _View {
    
    override public var frame: CGRect {
        didSet {
            #if os(iOS) || os(tvOS)
            setNeedsDisplay()
            #elseif os(macOS)
            setNeedsDisplay(frame)
            #endif
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        #if os(iOS) || os(tvOS)
        isUserInteractionEnabled = false
        #endif
        
    }
    
    #if os(iOS) || os(tvOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    func checkerImage() -> _Image {
        let scale: CGFloat = 20
        let dark: CGFloat = 1 / 3
        let light: CGFloat = 2 / 3
        #if os(iOS) || os(tvOS)
        let darkColor = UIColor(white: dark, alpha: 1.0).cgColor
        let lightColor = UIColor(white: light, alpha: 1.0).cgColor
        return UIGraphicsImageRenderer(size: CGSize(width: scale * 2, height: scale * 2)).image { ctx in
            ctx.cgContext.setFillColor(darkColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: 0, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: scale, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
            ctx.cgContext.setFillColor(lightColor)
            ctx.cgContext.addRect(CGRect(x: 0, y: scale, width: scale, height: scale))
            ctx.cgContext.addRect(CGRect(x: scale, y: 0, width: scale, height: scale))
            ctx.cgContext.drawPath(using: .fill)
        }
        #elseif os(macOS)
        let darkColor = CGColor(gray: dark, alpha: 1.0)
        let lightColor = CGColor(gray: light, alpha: 1.0)
        let img = NSImage(size: CGSize(width: scale * 2, height: scale * 2))
        img.lockFocus()
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(darkColor)
        ctx.fill(CGRect(x: 0, y: 0, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: scale, width: scale, height: scale))
        ctx.setFillColor(lightColor)
        ctx.fill(CGRect(x: 0, y: scale, width: scale, height: scale))
        ctx.fill(CGRect(x: scale, y: 0, width: scale, height: scale))
        img.unlockFocus()
        return img
        #endif
    }
    
    override public func draw(_ rect: CGRect) {
        
        #if os(iOS) || os(tvOS)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        #elseif os(macOS)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        #endif
        
        context.saveGState();
        
        let phase = CGSize(width: rect.width / 2, height: rect.height / 2)
        context.setPatternPhase(phase)
        
        let checker = checkerImage()
        
        #if os(iOS) || os(tvOS)
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

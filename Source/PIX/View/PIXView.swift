//
//  PIXView.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

#if os(iOS)
public typealias _View = UIView
#elseif os(macOS)
public typealias _View = NSView
#endif
public class PIXView: _View {
    
    let metalView: PIXMetalView

    var res: PIX.Res?

    var boundsReady: Bool { return bounds.width > 0 }

    public enum FillMode {
        case aspectFit
        case aspectFill
        case pixelPerfect
        case fill
    }
    /// Defaults to `.aspectFit`.
    public var fillMode: FillMode = .aspectFit { didSet { layoutFillMode() } }
    
    var widthLayoutConstraint: NSLayoutConstraint!
    var heightLayoutConstraint: NSLayoutConstraint!
    
    /// This enables a checker background view, the default is `true`.
    /// Disable if you have a transparent PIX and want views under the PIXView to show.
    public var checker: Bool = true { didSet { checkerView.isHidden = !checker } }
    let checkerView: CheckerView
    
    #if os(macOS)
    public override var frame: NSRect { didSet { _ = layoutFillMode() } }
    #endif
    
    init() {
        
        checkerView = CheckerView()

        metalView = PIXMetalView()
        
        super.init(frame: .zero)
        
        #if os(iOS)
        clipsToBounds = true
        #endif
        
        addSubview(checkerView)
        
        addSubview(metalView)
        
        autoLayout()
        
    }
    
    func autoLayout() {
        
        checkerView.translatesAutoresizingMaskIntoConstraints = false
        checkerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        checkerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkerView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        checkerView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        metalView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        widthLayoutConstraint = metalView.widthAnchor.constraint(equalToConstant: 1)
        heightLayoutConstraint = metalView.heightAnchor.constraint(equalToConstant: 1)
        widthLayoutConstraint.isActive = true
        heightLayoutConstraint.isActive = true
        
    }
    
    func layoutFillMode() {
        
        guard boundsReady else { return }
        guard let res = res else { return }
        
        let resolutionAspect = res.width / res.height
        let viewAspect = bounds.width / bounds.height
        let combinedAspect = resolutionAspect / viewAspect
        let dynamicAspect = resolutionAspect > viewAspect ? combinedAspect : 1 / combinedAspect
        
        let width: CGFloat
        let height: CGFloat
        switch fillMode {
        case .aspectFit:
            width = resolutionAspect >= viewAspect ? bounds.width : bounds.width / dynamicAspect
            height = resolutionAspect <= viewAspect ? bounds.height : bounds.height / dynamicAspect
        case .aspectFill:
            width = resolutionAspect <= viewAspect ? bounds.width : bounds.width * dynamicAspect
            height = resolutionAspect >= viewAspect ? bounds.height : bounds.height * dynamicAspect
        case .pixelPerfect:
            #if os(iOS)
            let scale: CGFloat = UIScreen.main.nativeScale
            #elseif os(macOS)
            let scale: CGFloat = 1.0
            #endif
            width = res.width / scale
            height = res.height / scale
        case .fill:
            width = bounds.width
            height = bounds.height
        }
        
        widthLayoutConstraint.constant = width
        heightLayoutConstraint.constant = height
        
        print("C", width, height)
        
        #if os(iOS)
        checkerView.setNeedsDisplay()
        #elseif os(macOS)
//        metalView.setNeedsDisplay(frame)
//        checkerView.setNeedsDisplay(frame)
//        layoutSubtreeIfNeeded()
//        metalView.needsLayout = true
//        metalView.needsUpdateConstraints = true
        #endif
        
    }
    
    func setRes(_ newRes: PIX.Res) {
        res = newRes
        metalView.res = newRes
        layoutFillMode()
        // FIXME: Set by user..
//        if !boundsReady {
//            #if os(iOS)
//            let scale: CGFloat = UIScreen.main.nativeScale
//            #elseif os(macOS)
//            let scale: CGFloat = 1.0
//            #endif
//            frame = CGRect(x: 0, y: 0, width: newRes.width / scale, height: newRes.height / scale)
//        }
    }
    
    #if os(iOS)
    public override func layoutSubviews() {
        super.layoutSubviews()
        _ = layoutFillMode()
    }
    #elseif os(macOS)
    public override func layout() {
        super.layout()
        _ = layoutFillMode()
    }
    #endif
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

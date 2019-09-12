//
//  PIXView.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

#if os(iOS) && targetEnvironment(simulator)
import MetalPerformanceShadersProxy
#else
import MetalKit
#endif

#if os(iOS)
import SwiftUI
#endif


#if os(iOS)
public struct PIXRepView: UIViewRepresentable {
        
    public let pix: PIX
    
    public init(pix: PIX) {
        self.pix = pix
    }
    
    public func makeUIView(context: Context) -> PIXView {
        return pix.view
    }
    
    public func updateUIView(_ pixView: PIXView, context: Context) {}
    
}
#endif

#if os(iOS)
public typealias _View = UIView
#elseif os(macOS)
public typealias _View = NSView
#endif
public class PIXView: _View {
    
    let metalView: PIXMetalView

    var res: PIX.Res?

    var boundsReady: Bool { return bounds.width > 0 }

    public enum Placement {
        case aspectFit
        case aspectFill
        case pixelPerfect
        case fill
    }
    /// Defaults to `.aspectFit`.
    public var placement: Placement = .aspectFit { didSet { layoutPlacement() } }
    
    var widthLayoutConstraint: NSLayoutConstraint!
    var heightLayoutConstraint: NSLayoutConstraint!
    
    /// This enables a checker background view, the default is `true`.
    /// Disable if you have a transparent PIX and want views under the PIXView to show.
    public var checker: Bool = true { didSet { checkerView.isHidden = !checker } }
    let checkerView: CheckerView
    
    #if os(iOS)
    let liveTouchView: LiveTouchView
    #elseif os(macOS)
    public let liveMouseView: LiveMouseView
    #endif
    
    #if os(macOS)
    public override var frame: NSRect { didSet { _ = layoutPlacement(); checkAutoRes() } }
    #endif
    
    init() {
        
        checkerView = CheckerView()

        metalView = PIXMetalView()
        
        #if os(iOS)
        liveTouchView = LiveTouchView()
        #elseif os(macOS)
        liveMouseView = LiveMouseView()
        #endif
        
        super.init(frame: .zero)
        
        #if os(iOS)
        clipsToBounds = true
        #endif
        
        addSubview(checkerView)
        
        addSubview(metalView)
        
        #if os(iOS)
        addSubview(liveTouchView)
        #elseif os(macOS)
        addSubview(liveMouseView)
        #endif
        
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
        
        #if os(iOS)
        liveTouchView.translatesAutoresizingMaskIntoConstraints = false
        liveTouchView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        liveTouchView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        liveTouchView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        liveTouchView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        #elseif os(macOS)
        liveMouseView.translatesAutoresizingMaskIntoConstraints = false
        liveMouseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        liveMouseView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        liveMouseView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        liveMouseView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        #endif
        
    }
    
    func layoutPlacement() {
        
        guard boundsReady else { return }
        guard let res = res else { return }
        
        let resolutionAspect = res.width.cg / res.height.cg
        let viewAspect = bounds.width / bounds.height
        let combinedAspect = resolutionAspect / viewAspect
        let dynamicAspect = resolutionAspect > viewAspect ? combinedAspect : 1 / combinedAspect
        
        let width: CGFloat
        let height: CGFloat
        switch placement {
        case .aspectFit:
            width = resolutionAspect >= viewAspect ? bounds.width : bounds.width / dynamicAspect
            height = resolutionAspect <= viewAspect ? bounds.height : bounds.height / dynamicAspect
        case .aspectFill:
            width = resolutionAspect <= viewAspect ? bounds.width : bounds.width * dynamicAspect
            height = resolutionAspect >= viewAspect ? bounds.height : bounds.height * dynamicAspect
        case .pixelPerfect:
            let scale: CGFloat = PIX.Res.scale.cg
            width = res.width.cg / scale
            height = res.height.cg / scale
        case .fill:
            width = bounds.width
            height = bounds.height
        }
        
        widthLayoutConstraint.constant = width
        heightLayoutConstraint.constant = height
        
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
    
    func setRes(_ newRes: PIX.Res?) {
        
        if let newRes = newRes {
            res = newRes
            metalView.res = newRes
            layoutPlacement()
        } else {
            widthLayoutConstraint.constant = 0
            heightLayoutConstraint.constant = 0
            #if os(iOS)
            checkerView.setNeedsDisplay()
            #endif
            metalView.res = nil
        }
        
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
    
    public func liveTouch(active: Bool) {
        #if os(iOS)
        liveTouchView.isUserInteractionEnabled = active
        #elseif os(macOS)
        liveMouseView.isUserInteractionEnabled = active
        #endif
    }
    
    public func touchEvent(_ callback: @escaping (Bool) -> ()) {
        liveTouchView.touchEvent { touch in
            callback(touch)
        }
    }
    
    public func touchPointEvent(_ callback: @escaping (CGPoint) -> ()) {
        liveTouchView.touchPointEvent { point in
            callback(point)
        }
    }
    
    public func touchUVEvent(_ callback: @escaping (CGPoint) -> ()) {
        liveTouchView.touchPointEvent { point in
            guard self.boundsReady else { return }
            let aspect = self.bounds.width / self.bounds.height
            let uv = CGPoint(x: (point.x + aspect / 2) / aspect, y: point.y + 0.5)
            callback(uv)
        }
    }
    
    #elseif os(macOS)
    
    public func liveMouse(active: Bool) {
        liveMouseView.isHidden = !active
    }
    
    #endif
    
    #if os(iOS)
    public override func layoutSubviews() {
        super.layoutSubviews()
        _ = layoutPlacement()
        checkAutoRes()
    }
    #elseif os(macOS)
    public override func layout() {
        super.layout()
        _ = layoutPlacement()
        checkAutoRes()
    }
    #endif
    
    func checkAutoRes() {
        for pix in PixelKit.main.linkedPixs {
            if let pixRes = pix as? PIXRes {
                if pixRes.res == .auto {
                    pix.applyRes {
                        pix.setNeedsRender()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

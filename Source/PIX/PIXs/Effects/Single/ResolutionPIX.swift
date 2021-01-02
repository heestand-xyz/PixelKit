//
//  ResolutionPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-03.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics
#if canImport(SwiftUI)
import SwiftUI
#endif

//#if canImport(SwiftUI)
//@available(iOS 13.0.0, *)
//@available(OSX 10.15, *)
//@available(tvOS 13.0.0, *)
//public struct ResolutionPIXUI: View, PIXUI {
//    public var node: NODE { pix }
//    public let pix: PIX
//    let resolutionPix: ResolutionPIX
//    public var body: some View {
//        NODERepView(node: pix)
//    }
//    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), _ uiPix: () -> (NODEUI)) {
//        resolutionPix = ResolutionPIX(at: resolution)
//        pix = resolutionPix
//        resolutionPix.resolution = resolution
//        resolutionPix.input = uiPix().node as? (PIX & NODEOut)
//    }
//    public func placement(_ placement: Placement) -> ResolutionPIXUI {
//        resolutionPix.placement = placement
//        return self
//    }
//}
//#endif

public class ResolutionPIX: PIXSingleEffect, NODEResolution {

    override open var shaderName: String { return "effectSingleResPIX" }
    override open var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    public var resMultiplier: CGFloat = 1 { didSet { applyResolution { self.setNeedsRender() } } }
    public var inheritInResolution: Bool = false { didSet { applyResolution { self.setNeedsRender() } } } // CHECK upstream resolution exists
    public var placement: Placement = .fit { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(placement.index)]
    }
    
    // MARK: - Life Cycle
    
    required public init(at resolution: Resolution) {
        self.resolution = resolution
        super.init(name: "Resolution", typeName: "pix-effect-single-resolution")
    }
    
    required init() {
        self.resolution = ._128
        super.init()
    }
    
}

public extension NODEOut {
    
    func _reRes(to resolution: Resolution) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: resolution)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        return resPix
    }
    
    func _reRes(by resMultiplier: CGFloat) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: ._128)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.inheritInResolution = true
        resPix.resMultiplier = resMultiplier
        return resPix
    }
    
}

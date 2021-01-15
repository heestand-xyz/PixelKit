//
//  ResolutionPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-03.
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
    
    @LiveResolution public var resolution: Resolution
    @LiveResolution public var resMultiplier: CGFloat = 1
    @LiveResolution public var inheritInResolution: Bool = false
    @Live public var placement: Placement = .fit
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _resMultiplier, _inheritInResolution, _placement]
    }
    
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
    
    @available(*, deprecated, renamed: "resolution(_:)")
    func _reRes(to res: Resolution) -> ResolutionPIX {
        resolution(res)
    }
    func resolution(_ res: Resolution) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: res)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        return resPix
    }
    
    @available(*, deprecated, renamed: "scaleResolution(by:)")
    func _reRes(by resMultiplier: CGFloat) -> ResolutionPIX {
        scaleResolution(by: resMultiplier)
    }
    func scaleResolution(by resMultiplier: CGFloat) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: ._128)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.inheritInResolution = true
        resPix.resMultiplier = resMultiplier
        return resPix
    }
    
}

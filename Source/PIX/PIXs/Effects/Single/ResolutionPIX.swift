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

final public class ResolutionPIX: PIXSingleEffect, NODEResolution, PIXViewable, ObservableObject {

    override public var shaderName: String { return "effectSingleResPIX" }
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveResolution public var resolution: Resolution
    @LiveResolution public var resMultiplier: CGFloat = 1
    @LiveResolution public var inheritInResolution: Bool = false
    @Live public var placement: Placement = .fit
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _resMultiplier, _inheritInResolution, _placement]
    }
    
    public override var uniforms: [CGFloat] {
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
    
    func pixScaleResolution(to res: Resolution = .auto(render: PixelKit.main.render),
                            placement: Placement = .fit,
                            interpolate: InterpolateMode = .linear) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: res)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.interpolate = interpolate
        resPix.placement = placement
        return resPix
    }
    
    func pixScaleResolution(by resMultiplier: CGFloat,
                            placement: Placement = .fit,
                            interpolate: InterpolateMode = .linear) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: ._128)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.inheritInResolution = true
        resPix.resMultiplier = resMultiplier
        resPix.interpolate = interpolate
        resPix.placement = placement
        return resPix
    }
    
}

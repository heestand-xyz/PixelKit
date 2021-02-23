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
    
    @LiveResolution(name: "Resolution") public var resolution: Resolution = .square(1)
    @LiveFloat(name: "Resolution Multiplier", updateResolution: true) public var resolutionMultiplier: CGFloat = 1
    @LiveBool(name: "Inherit Resolution", updateResolution: true) public var inheritResolution: Bool = false
    @LiveEnum(name: "Placement") public var placement: Placement = .fit
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _resolutionMultiplier, _inheritResolution, _placement]
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
        resPix.inheritResolution = true
        resPix.resolutionMultiplier = resMultiplier
        resPix.interpolate = interpolate
        resPix.placement = placement
        return resPix
    }
    
}

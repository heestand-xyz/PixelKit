//
//  ResolutionPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-03.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import CoreGraphics
#if canImport(SwiftUI)
import SwiftUI
#endif

final public class ResolutionPIX: PIXSingleEffect, NODEResolution, PIXViewable {
    
    public typealias Model = ResolutionPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleResolutionPIX" }
    override public var shaderNeedsResolution: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    @LiveFloat("resolutionMultiplier", range: 0.5...2.0, updateResolution: true) public var resolutionMultiplier: CGFloat = 1
    @LiveBool("inheritResolution", updateResolution: true) public var inheritResolution: Bool = false
    @LiveEnum("placement") public var placement: Placement = .fit
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _resolutionMultiplier, _inheritResolution, _placement] + super.liveList
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(placement.index)]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    required public init(at resolution: Resolution) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        resolutionMultiplier = model.resolutionMultiplier
        inheritResolution = model.inheritResolution
        placement = model.placement
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        model.resolutionMultiplier = resolutionMultiplier
        model.inheritResolution = inheritResolution
        model.placement = placement
        
        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixScaleResolution(to res: Resolution = .auto,
                            placement: Placement = .fit,
                            interpolation: PixelInterpolation = .linear) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: res)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.interpolation = interpolation
        resPix.placement = placement
        return resPix
    }
    
    func pixScaleResolution(by resMultiplier: CGFloat,
                            placement: Placement = .fit,
                            interpolation: PixelInterpolation = .linear) -> ResolutionPIX {
        let resPix = ResolutionPIX(at: ._128)
        resPix.name = "reRes:res"
        resPix.input = self as? PIX & NODEOut
        resPix.inheritResolution = true
        resPix.resolutionMultiplier = resMultiplier
        resPix.interpolation = interpolation
        resPix.placement = placement
        return resPix
    }
    
}

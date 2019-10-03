//
//  ResPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-03.
//  Open Source - MIT License
//

import CoreGraphics
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ResPIXUI: View, PIXUI {
    public let pix: PIX
    let resPix: ResolutionPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }
    public init(res: Resolution = .auto, _ uiPix: () -> (PIXUI)) {
        resPix = ResPIX(res: res)
        pix = resPix
        resPix.res = res
        resPix.inPix = uiPix().pix as? (PIX & NODEOut)
    }
    public func placement(_ placement: PIX.Placement) -> ResPIXUI {
        resPix.placement = placement
        return self
    }
}
#endif

public class ResPIX: PIXSingleEffect, PIXRes {

    override open var shaderName: String { return "effectSingleResPIX" }
    override open var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var res: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    public var resMultiplier: CGFloat = 1 { didSet { applyResolution { self.setNeedsRender() } } }
    public var inheritInRes: Bool = false { didSet { applyResolution { self.setNeedsRender() } } } // CHECK upstream resolution exists
    public var placement: Placement = .aspectFit { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(placement.index)]
    }
    
    // MARK: - Life Cycle
    
    required public init(res: Resolution) {
        self.res = res
        super.init()
        name = "res"
    }
    
    required init() {
        self.res = ._128
        super.init()
    }
    
}

public extension NODEOut {
    
    func _reRes(to res: Resolution) -> ResPIX {
        let resPix = ResPIX(res: res)
        resPix.name = "reRes:res"
        resPix.inPix = self as? PIX & NODEOut
        return resPix
    }
    
    func _reRes(by resMultiplier: CGFloat) -> ResPIX {
        let resPix = ResPIX(res: ._128)
        resPix.name = "reRes:res"
        resPix.inPix = self as? PIX & NODEOut
        resPix.inheritInRes = true
        resPix.resMultiplier = resMultiplier
        return resPix
    }
    
}

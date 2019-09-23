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
    let resPix: ResPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }
    public init(res: PIX.Res = .auto, _ uiPix: () -> (PIXUI)) {
        resPix = ResPIX(res: res)
        pix = resPix
        resPix.res = res
        resPix.inPix = uiPix().pix as? (PIX & PIXOut)
    }
}
#endif

public class ResPIX: PIXSingleEffect, PIXRes {

    override open var shader: String { return "effectSingleResPIX" }
    override open var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var res: Res { didSet { applyRes { self.setNeedsRender() } } }
    public var resMultiplier: CGFloat = 1 { didSet { applyRes { self.setNeedsRender() } } }
    public var inheritInRes: Bool = false { didSet { applyRes { self.setNeedsRender() } } } // CHECK upstream resolution exists
    public var placement: Placement = .aspectFit { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(placement.index)]
    }
    
    // MARK: - Life Cycle
    
    required public init(res: Res) {
        self.res = res
        super.init()
        name = "res"
    }
    
    required init() {
        self.res = ._128
        super.init()
    }
    
}

public extension PIXOut {
    
    func _reRes(to res: PIX.Res) -> ResPIX {
        let resPix = ResPIX(res: res)
        resPix.name = "reRes:res"
        resPix.inPix = self as? PIX & PIXOut
        return resPix
    }
    
    func _reRes(by resMultiplier: CGFloat) -> ResPIX {
        let resPix = ResPIX(res: ._128)
        resPix.name = "reRes:res"
        resPix.inPix = self as? PIX & PIXOut
        resPix.inheritInRes = true
        resPix.resMultiplier = resMultiplier
        return resPix
    }
    
}

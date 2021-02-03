//
//  CrossPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-21.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

final public class CrossPIX: PIXMergerEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectMergerCrossPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var fraction: CGFloat = 0.5
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_fraction] + super.liveList
    }
    
    override public var values: [Floatable] {
        [fraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Cross", typeName: "pix-effect-merger-cross")
    }
    
}

//public extension NODEOut {
//    
//    func cross(with pix: PIX & NODEOut, fraction: CGFloat) -> CrossPIX {
//        let crossPix = CrossPIX()
//        crossPix.name = ":cross:"
//        crossPix.inputA = self as? PIX & NODEOut
//        crossPix.inputB = pix
//        crossPix.fraction = fraction
//        return crossPix
//    }
//    
//}

public func pixCross(_ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut, at fraction: CGFloat) -> CrossPIX {
    let crossPix = CrossPIX()
    crossPix.name = ":cross:"
    crossPix.inputA = pixA
    crossPix.inputB = pixB
    crossPix.fraction = fraction
    return crossPix
}

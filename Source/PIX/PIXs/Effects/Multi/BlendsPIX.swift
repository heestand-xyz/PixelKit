//
//  BlendsPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-14.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics

public class BlendsPIX: PIXMultiEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMultiBlendsPIX" }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendMode = .add { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum BlendsCodingKeys: String, CodingKey {
//        case blendingMode
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Blends", typeName: "pix-effect-multi-blends")
    }
    
}

// MARK: - Loop

public func loop(_ count: Int, blendMode: BlendMode, extend: ExtendMode = .zero, loop: (LiveInt, LiveFloat) -> (PIX & NODEOut)) -> BlendsPIX {
    let blendsPix = BlendsPIX()
    blendsPix.name = "loop:blends"
    blendsPix.blendMode = blendMode
    blendsPix.extend = extend
    for i in 0..<count {
        let fraction = LiveFloat(i) / LiveFloat(count)
        let pix = loop(LiveInt(i), fraction)
        pix.name = "\(pix.name):\(i)"
        blendsPix.inputs.append(pix)
    }
    return blendsPix
}

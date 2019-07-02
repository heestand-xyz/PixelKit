//
//  BlendsPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-14.
//  Open Source - MIT License
//

import CoreGraphics

public class BlendsPIX: PIXMultiEffect, PIXAuto {
    
    override open var shader: String { return "effectMultiBlendsPIX" }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendingMode = .add { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum BlendsCodingKeys: String, CodingKey {
//        case blendingMode
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "blends"
    }
    
    // MARK: - Loop

    public static func loop(_ count: Int, blendMode: BlendingMode, extend: PIX.ExtendMode = .zero, loop: (LiveInt, LiveFloat) -> (PIX & PIXOut)) -> BlendsPIX {
        let blendsPix = BlendsPIX()
        blendsPix.name = "loop:blends"
        blendsPix.blendMode = blendMode
        blendsPix.extend = extend
        for i in 0..<count {
            let fraction = LiveFloat(i) / LiveFloat(count)
            let pix = loop(LiveInt(i), fraction)
            blendsPix.inPixs.append(pix)
        }
        return blendsPix
    }
    
}

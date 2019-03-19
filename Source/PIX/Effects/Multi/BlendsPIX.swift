//
//  BlendsPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-14.
//  Open Source - MIT License
//
import CoreGraphics//x

public class BlendsPIX: PIXMultiEffect {
    
    override open var shader: String { return "effectMultiBlendsPIX" }
    
    // MARK: - Public Properties
    
    public var mode: BlendingMode = .add { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum BlendsCodingKeys: String, CodingKey {
//        case blendingMode
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(mode.index)]
    }

    public static func loop(_ range: Range<Int>, with mode: BlendingMode, extend: PIX.ExtendMode = .zero, loop: (LiveInt, LiveFloat) -> (PIX & PIXOut)) -> BlendsPIX {
        let blendsPix = BlendsPIX()
        blendsPix.name = "loop:blends"
        blendsPix.mode = mode
        blendsPix.extend = extend
        for i in range {
            let fraction = LiveFloat(i) / LiveFloat(range.upperBound - 1)
            let pix = loop(LiveInt(i), fraction)
            blendsPix.inPixs.append(pix)
        }
        return blendsPix
    }
    
}

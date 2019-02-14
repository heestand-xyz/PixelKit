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
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum BlendsCodingKeys: String, CodingKey {
//        case blendingMode
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index)]
    }
    
}

//
//  SlopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//
import CoreGraphics//x

public class SlopePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    public var amplitude: CGFloat = 1.0 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case amplitude
//    }
    
    open override var uniforms: [CGFloat] {
        return [amplitude]
    }
    
}

public extension PIXOut {
    
    func _slope(_ amplitude: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.inPix = self as? PIX & PIXOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}

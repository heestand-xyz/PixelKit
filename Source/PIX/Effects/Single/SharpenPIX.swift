//
//  SharpenPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//
import CoreGraphics//x

public class SharpenPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleSharpenPIX" }
    
    // MARK: - Public Properties
    
    public var contrast: CGFloat = 1.0 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case contrast
//    }
    
    open override var uniforms: [CGFloat] {
        return [contrast]
    }
    
    public override required init() {
        super.init()
    }
    
}

public extension PIXOut {
    
    func _sharpen(_ contrast: CGFloat = 1.0) -> SharpenPIX {
        let sharpenPix = SharpenPIX()
        sharpenPix.name = ":sharpen:"
        sharpenPix.inPix = self as? PIX & PIXOut
        sharpenPix.contrast = contrast
        return sharpenPix
    }
    
}

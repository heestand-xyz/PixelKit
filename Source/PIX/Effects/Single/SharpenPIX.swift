//
//  SharpenPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//


public class SharpenPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleSharpenPIX" }
    
    // MARK: - Public Properties
    
    public var contrast: CGFloat = 1.0 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case contrast
    }
    
    open override var uniforms: [CGFloat] {
        return [contrast]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contrast = try container.decode(CGFloat.self, forKey: .contrast)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contrast, forKey: .contrast)
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

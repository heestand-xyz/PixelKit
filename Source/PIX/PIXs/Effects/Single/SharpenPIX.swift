//
//  SharpenPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

final public class SharpenPIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectSingleSharpenPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var contrast: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_contrast]
    }
    
    override public var values: [Floatable] {
        [contrast]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Sharpen", typeName: "pix-effect-single-sharpen")
    }
    
}

public extension NODEOut {
    
    func pixSharpen(_ contrast: CGFloat = 1.0) -> SharpenPIX {
        let sharpenPix = SharpenPIX()
        sharpenPix.name = ":sharpen:"
        sharpenPix.input = self as? PIX & NODEOut
        sharpenPix.contrast = contrast
        return sharpenPix
    }
    
}

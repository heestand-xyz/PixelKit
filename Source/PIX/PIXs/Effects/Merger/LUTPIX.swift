//
//  LUTPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-03-12.
//

import Foundation
import LiveValues
import RenderKit

public class LUTPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [LiveFloat(0), LiveFloat(0)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
//        extend = .hold
        name = "LUT"
    }
    
    public static func lutMap() -> MetalPIX {
        MetalPIX(at: .square(256 * Int(sqrt(256.0))), code:
            """
            pix = float4(uv.x, uv.y, 1, 1);
            """
        )
    }
    
}

public extension NODEOut {
    
    func _lut(with pix: PIX & NODEOut) -> LUTPIX {
        let lutPix = LUTPIX()
        lutPix.name = ":LUT:"
        lutPix.inputA = self as? PIX & NODEOut
        lutPix.inputB = pix
        return lutPix
    }
    
}

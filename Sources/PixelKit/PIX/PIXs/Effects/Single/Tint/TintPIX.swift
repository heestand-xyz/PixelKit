//
//  TintPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-10.
//

import RenderKit
import Resolution
import Foundation
import PixelColor

final public class TintPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleTintPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor("color") public var color: PixelColor = .orange
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_color]
    }
    
    override public var values: [Floatable] {
        [color]
    }
    
    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Tint", typeName: "pix-effect-single-tint")
    }
    
}

public extension NODEOut {
    
    func pixTint(_ color: PixelColor) -> TintPIX {
        let tintPix = TintPIX()
        tintPix.name = ":tint:"
        tintPix.input = self as? PIX & NODEOut
        tintPix.color = color
        return tintPix
    }
    
}


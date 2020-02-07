//
//  NilPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-15.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class NilPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    let nilOverrideBits: LiveColor.Bits?
    public override var overrideBits: LiveColor.Bits? { nilOverrideBits }
    
    public required init() {
        nilOverrideBits = nil
        super.init()
        name = "nil"
    }
    
    public init(overrideBits: LiveColor.Bits) {
        nilOverrideBits = overrideBits
        super.init()
        name = "nil\(overrideBits.rawValue)"
    }
    
}

public extension NODEOut {
    
    func _node() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = "node:nil"
        nilPix.input = self as? PIX & NODEOut
        nilPix.bypass = true
        return nilPix
    }
    
    func _nil() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.input = self as? PIX & NODEOut
        return nilPix
    }
    
}

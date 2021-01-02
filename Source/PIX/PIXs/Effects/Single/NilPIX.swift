//
//  NilPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-15.
//  Open Source - MIT License
//


import RenderKit

public class NilPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    let nilOverrideBits: Bits?
    public override var overrideBits: Bits? { nilOverrideBits }
    
    public required init() {
        nilOverrideBits = nil
        super.init(name: "Nil", typeName: "pix-effect-single-nil")
    }
    
    public init(overrideBits: Bits) {
        nilOverrideBits = overrideBits
        super.init(name: "Nil (\(overrideBits.rawValue)bit)", typeName: "pix-effect-single-nil")
    }
    
}

public extension NODEOut {
    
    @available(*, deprecated, renamed: "_nil(bypass:)")
    func _node() -> NilPIX {
        _nil(bypass: true)
    }
    
    /// bypass is `false` by *default*
    func _nil(bypass: Bool = false) -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.input = self as? PIX & NODEOut
        nilPix.bypass = bypass
        return nilPix
    }
    
}

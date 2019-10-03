//
//  NilPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-15.
//  Open Source - MIT License
//

public class NilPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    public required init() {
        super.init()
        name = "nil"
    }
}

public extension NODEOut {
    
    func _node() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = "node:nil"
        nilPix.inPix = self as? PIX & NODEOut
        nilPix.bypass = true
        return nilPix
    }
    
    func _nil() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.inPix = self as? PIX & NODEOut
        return nilPix
    }
    
}

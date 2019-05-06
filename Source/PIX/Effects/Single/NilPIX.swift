//
//  NilPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-15.
//  Open Source - MIT License
//

public class NilPIX: PIXSingleEffect {
    
    override open var shader: String { return "nilPIX" }
    
}

public extension PIXOut {
    
    func _node() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = "node:nil"
        nilPix.inPix = self as? PIX & PIXOut
        nilPix.bypass = true
        return nilPix
    }
    
    func _nil() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.inPix = self as? PIX & PIXOut
        return nilPix
    }
    
}

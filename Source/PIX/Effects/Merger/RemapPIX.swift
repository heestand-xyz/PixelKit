//
//  RemapPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

public class RemapPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerRemapPIX" }
    
}

public extension PIXOut {
    
    func _remap(with pix: PIX & PIXOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inPixA = self as? PIX & PIXOut
        remapPix.inPixB = pix
        return remapPix
    }
    
}

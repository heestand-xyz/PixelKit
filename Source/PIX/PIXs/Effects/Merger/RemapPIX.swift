//
//  RemapPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

public class RemapPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerRemapPIX" }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "remap"
    }
    
}

public extension NODEOut {
    
    func _remap(with pix: PIX & NODEOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inPixA = self as? PIX & NODEOut
        remapPix.inPixB = pix
        return remapPix
    }
    
}

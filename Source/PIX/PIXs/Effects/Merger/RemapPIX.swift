//
//  RemapPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

import RenderKit

public class RemapPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerRemapPIX" }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Remap", typeName: "pix-effect-merger-remap")
    }
    
}

public extension NODEOut {
    
    func _remap(with pix: PIX & NODEOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inputA = self as? PIX & NODEOut
        remapPix.inputB = pix
        return remapPix
    }
    
}

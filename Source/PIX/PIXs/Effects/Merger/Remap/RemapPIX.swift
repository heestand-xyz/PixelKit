//
//  RemapPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution

final public class RemapPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerRemapPIX" }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Remap", typeName: "pix-effect-merger-remap")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    func pixRemap(pix: () -> (PIX & NODEOut)) -> RemapPIX {
        pixRemap(pix: pix())
    }
    func pixRemap(pix: PIX & NODEOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inputA = self as? PIX & NODEOut
        remapPix.inputB = pix
        return remapPix
    }
    
}

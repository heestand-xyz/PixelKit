//
//  RemapPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func remap(pix: PIX & PIXOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.inPixA = self as? PIX & PIXOut
        remapPix.inPixB = pix
        return remapPix
    }
    
}

public class RemapPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .remap
    
    override var shader: String { return "effectMergerRemapPIX" }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {}
    
    
}

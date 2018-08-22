//
//  NilPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-15.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class NilPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .nil
    
    override var shader: String { return "effectSingleNilPIX" }
    
    public override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

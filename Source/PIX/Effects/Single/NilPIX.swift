//
//  NilPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-15.
//  Copyright © 2018 Hexagons. All rights reserved.
//

public extension PIXOut {
    
    func node() -> NilPIX {
        let nilPix = NilPIX()
        nilPix.inPix = self as? PIX & PIXOut
        nilPix.bypass = true
        return nilPix
    }
    
}

public class NilPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .nil
    
    override open var shader: String { return "nilPIX" }
    
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

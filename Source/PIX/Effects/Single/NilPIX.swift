//
//  NilPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-15.
//  Copyright © 2018 Hexagons. All rights reserved.
//

public class NilPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .nil
    
    override var shader: String { return "nilPIX" }
    
}

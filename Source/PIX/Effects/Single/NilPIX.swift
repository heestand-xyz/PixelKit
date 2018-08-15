//
//  NilPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-15.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class NilPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .nil
    
    public override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

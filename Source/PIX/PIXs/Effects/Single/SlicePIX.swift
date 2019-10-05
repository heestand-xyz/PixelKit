//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-05.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class SlicePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleSlicePIX" }
    
    public required init() {
        super.init()
        name = "slice"
    }
}

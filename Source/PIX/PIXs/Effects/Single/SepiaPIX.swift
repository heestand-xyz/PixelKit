//
//  SepiaPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//


import RenderKit
import Foundation

public class SepiaPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleSepiaPIX" }
    
    // MARK: - Public Properties
    
    public var color: LiveColor = .orange
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [color]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Sepia", typeName: "pix-effect-single-sepia")
    }
    
}

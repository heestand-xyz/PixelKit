//
//  SepiaPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SepiaPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleSepiaPIX" }
    
    // MARK: - Public Properties
    
    public var color: LiveColor = .orange
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [color]
    }
    
}

//
//  ConvertPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public class ConvertPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum ConvertMode: String, CaseIterable {
        case equirectangular
        case dome
        var index: Int {
            switch self {
            case .equirectangular: return 0
            case .dome: return 1
            }
        }
    }
    public var mode: ConvertMode = .dome
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(mode.index)]
    }
    
}

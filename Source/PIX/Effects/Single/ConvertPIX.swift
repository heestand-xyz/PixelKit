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
        case domeToEquirectangular
        case equirectangularToDome
//        case cubeToEquirectangular
        case squareToCircle
        case circleToSquare
        var index: Int {
            switch self {
            case .domeToEquirectangular: return 0
            case .equirectangularToDome: return 1
//            case .cubeToEquirectangular: return 2
            case .squareToCircle: return 4
            case .circleToSquare: return 5
            }
        }
    }
    public var mode: ConvertMode = .squareToCircle
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(mode.index)]
    }
    
}

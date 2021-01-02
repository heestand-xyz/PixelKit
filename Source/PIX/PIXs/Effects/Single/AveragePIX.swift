//
//  AveragePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-05.
//

import CoreGraphics


public class AveragePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleAveragePIX" }
    
    // MARK: - Public Properties
    
    public enum Axis {
        case x
        case y
        case z
        var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
    }
    public var axis: Axis = .z { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers

    public override var uniforms: [CGFloat] {
        [CGFloat(axis.index)]
    }
    
    public required init() {
        super.init(name: "Average", typeName: "")
    }
    
}

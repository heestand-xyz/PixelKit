//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import CoreGraphics
import RenderKit

public class SlicePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleSlicePIX" }
    
    // MARK: - Public Properties
    
    public var fraction: CGFloat = 0.5
    public enum Axis: Floatable {
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
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    public var axis: Axis = .z { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        [fraction, axis]
    }
    
    public required init() {
        super.init(name: "Slice", typeName: "pix-effect-single-slice")
    }
}

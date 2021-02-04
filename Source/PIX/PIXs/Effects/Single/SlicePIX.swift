//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to sample depth images.
final public class SlicePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleSlicePIX" }
    
    // MARK: - Public Properties
    
    @Live public var fraction: CGFloat = 0.5
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
        public init(floats: [CGFloat]) {
            let index: Int = Int(floats.first ?? 0.0)
            switch index {
            case 0:
                self = .x
            case 1:
                self = .y
            case 2:
                self = .z
            default:
                self = .x
            }
        }
    }
    @Live public var axis: Axis = .z
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_fraction, _axis]
    }
    
    override public var values: [Floatable] {
        [fraction, axis]
    }
    
    public required init() {
        super.init(name: "Slice", typeName: "pix-effect-single-slice")
    }
}

//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to sample depth images.
public class SlicePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleSlicePIX" }
    
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

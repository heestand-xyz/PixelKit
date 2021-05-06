//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

/// Useful with **VoxelKit** to sample depth images.
final public class SlicePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleSlicePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("fraction") public var fraction: CGFloat = 0.5
    public enum Axis: String, Enumable {
        case x
        case y
        case z
        public var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
        public var name: String {
            switch self {
            case .x: return "X"
            case .y: return "Y"
            case .z: return "Z"
            }
        }
    }
    @LiveEnum("axis") public var axis: Axis = .z
    
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
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
